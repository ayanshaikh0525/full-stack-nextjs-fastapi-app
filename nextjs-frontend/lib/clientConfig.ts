import { client } from "@/app/openapi-client/client.gen";

const configureClient = () => {
  const baseURL = process.env.NEXT_PUBLIC_API_URL;
  console.log("BASE URL: ", baseURL);
  client.setConfig({
    baseURL: baseURL,
  });
};

configureClient();
