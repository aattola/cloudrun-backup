import { google } from "npm:googleapis";
const sql = google.sql("v1beta4");

async function main() {
  const auth = new google.auth.GoogleAuth({
    // Scopes can be specified either as an array or as a single, space-delimited string.
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });

  // Acquire an auth client, and bind it to all future calls
  const authClient = await auth.getClient();
  google.options({ auth: authClient });

  // Do the magic
  const res = await sql.instances.export({
    // Cloud SQL instance ID. This does not include the project ID.
    instance: "tietoinenkanta",
    // Project ID of the project that contains the instance to be exported.
    project: "taikuri",

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
  console.log(res.data);
}

main().catch((e) => {
  console.error(e);
  throw e;
});
