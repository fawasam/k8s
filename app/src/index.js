const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok", uptime: process.uptime() });
});

app.get("/", (req, res) => {
  res.json({
    message: "Hello from Kubernetes!",
    version: process.env.APP_VERSION || "5.0.0",
    pod: process.env.HOSTNAME || "local",
    ts: new Date().toISOString(),
    // from ConfigMap
    appEnv: process.env.APP_ENV,
    dbHost: process.env.DB_HOST,
    // from Secret (never log real secrets — this is just for learning)
    dbUser: process.env.DB_USER,
    hasDbPassword: !!process.env.DB_PASSWORD, // just confirm it exists
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

