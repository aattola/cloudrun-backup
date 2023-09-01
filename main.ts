import { google, sql_v1beta4 } from "npm:googleapis";
import { poll } from "./utils.ts";

const sql = google.sql("v1beta4");

const PROJECT = "taikuri";
async function main() {
  const auth = new google.auth.GoogleAuth({
    // Scopes can be specified either as an array or as a single, space-delimited string.
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });

  google.options({ auth: auth });

  // Do the magic
  const res = await sql.instances.export({
    // Cloud SQL instance ID. This does not include the project ID.
    instance: "tietoinenkanta",
    // Project ID of the project that contains the instance to be exported.
    project: PROJECT,

    // Request body metadata
    requestBody: {
      // request body parameters
      // {
      //   "exportContext": {}
      // }
      exportContext: {
        databases: ["tietokanta"],
        fileType: "SQL",
        kind: "sql#exportContext",
        offload: false,
        sqlExportOptions: {},
        uri: "gs://tietokanta-backups/tietokanta.sql.gz",
      },
    },
  });

  const operationUUID = res.data.name as string;

  if (!operationUUID) throw new Error("No operation UUID");

  const pollingStarted = Date.now();

  type SOperation = sql_v1beta4.Schema$Operation;
  type OperationReturn = Awaited<{ data: SOperation }>;

  // returns true if we need to continiue polling
  const checkIfDone = (op: OperationReturn) => {
    // check if timeout
    if (Date.now() - pollingStarted > 1000 * 60 * 5)
      throw new Error("4min Timeout");

    if (op.data.status === "RUNNING") return true;
    if (op.data.status === "ERROR") throw new Error("Operation failed");
    if (op.data.status === "PENDING") return true;
    return false;
  };

  const result = await poll<OperationReturn>(
    () =>
      sql.operations.get({
        operation: operationUUID,
        project: PROJECT,
      }),
    checkIfDone,
    1000
  );
  console.log("Done: ", result.data.name);
}

main().catch((e) => {
  console.log(e)
  console.log(e?.response?.data?.error)
  console.log(e?.response?.data?.error?.message)
  console.log(e?.response?.data?.error?.errors[0])
  Deno.exit(1);
});
