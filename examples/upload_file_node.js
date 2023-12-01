const http = require("http"); // NOTE: use `https` for production/staging
const fs = require("fs");

const HOST = "http://localhost:3000";
const CREDENTIALS = {
  email: "admin@example.org",
  password: "decidim123456789",
};

// This is a basic implementation for sending multipart form data to the server
// in order to avoid external dependencies. The default node implementation of
// the FormData cannot be converted to a buffer or a string to be sent over
// HTTP.
const multipartData = (formData) => {
  let boundary = "--------------------------";
  for (let i = 0; i < 24; i++) {
    boundary += Math.floor(Math.random() * 10).toString(16);
  }

  const br = "\r\n";
  const chunks = [];
  formData.forEach((data) => {
    let header = `${chunks.length > 0 ? br : ""}--${boundary}${br}Content-Disposition: form-data; name="${data.name}"`;
    if (data.options) {
      if (data.options.filename) {
        header += `; filename="${data.options.filename}"`;
      }
      if (data.options.contentType) {
        header += `${br}Content-Type: ${data.options.contentType}`;
      }
    }

    chunks.push(Buffer.from(`${header}${br}${br}`));

    if (Buffer.isBuffer(data.value)) {
      chunks.push(data.value);
    } else {
      chunks.push(Buffer.from(data.value));
    }
  });
  chunks.push(Buffer.from(`${br}--${boundary}--${br}`));

  return {
    buffer: Buffer.concat(chunks),
    boundary
  };
};

const httpRequest = (url, method, data, headers) => {
  const uri = new URL(url);

  let contentType = "application/x-www-form-urlencoded";
  if (data) {
    contentType = `multipart/form-data; boundary=${data.boundary}`;
  }

  return new Promise((resolve, reject) => {
    const request = http.request({
      host: uri.hostname,
      port: uri.port,
      path: uri.pathname,
      headers: { "Content-Type": contentType, ...headers },
      method
    }, (resp) => {
      let responseData = "";

      resp.on("data", chunk => {
        responseData += chunk;
      });

      resp.on("end", () => {
        resolve({
          response: resp,
          data: responseData
        })
      });
    });

    request.on("error", err => {
      reject(new Error(`Error: ${err.message}`));
    });

    if (data) {
      request.write(data.buffer);
    }

    request.end();
  });
};

const runExample = async () => {
  // Authenticate with the API through the `POST /api/sign_in` endpoint
  const authForm = [
    { name: "user[email]", value: CREDENTIALS.email },
    { name: "user[password]", value: CREDENTIALS.password }
  ];
  const auth = await httpRequest(`${HOST}/api/sign_in`, "POST", multipartData(authForm));
  console.log(`Auth response code: ${auth.response.statusCode}`);
  if (auth.response.statusCode !== 200) {
    throw new Error("Invalid credentials provided!");
  }
  const authHeader = auth.response.headers.authorization;
  console.log(`Auth header: ${authHeader}`);

  // Send the file to the `POST /api/blobs` endpoint
  const readBuffer = fs.readFileSync(`${__dirname}/city.jpeg`);
  const uploadForm = [
    { name: "file", value: readBuffer, options: { filename: "city.jpeg", contentType: "image/jpeg" } }
  ];
  const upload = await httpRequest(`${HOST}/api/blobs`, "POST", multipartData(uploadForm), { "Authorization": authHeader });
  console.log(`Upload response code: ${upload.response.statusCode}`);
  if (upload.response.statusCode !== 200) {
    if (upload.response.statusCode === 422) {
      console.log(JSON.parse(upload.data));
    }
    throw new Error("Upload failed!");
  }
  console.log("Blob details:");
  console.log(JSON.parse(upload.data));

  // Sign out from the API (i.e. revoke the JWT token) through the `DELETE /api/sign_out` endpoint
  const signout = await httpRequest(`${HOST}/api/sign_out`, "DELETE", null, { "Authorization": authHeader });
  console.log(`Signout response code: ${signout.response.statusCode}`);
  if (signout.response.statusCode !== 200) {
    throw new Error("Sign out failed!");
  }
};

runExample();
