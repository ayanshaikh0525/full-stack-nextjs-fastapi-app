import { client } from "@/app/openapi-client/client.gen";

const configureClient = () => {
  const baseURL = process.env.NEXT_PUBLIC_API_BASE_URL;
  console.log("BASE URL:", baseURL);
  client.setConfig({
    baseURL: "http://localhost:8000",
  });
};

configureClient();
