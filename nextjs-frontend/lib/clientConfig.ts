import { client } from "@/app/openapi-client/client.gen";

const configureClient = () => {
  const baseURL = process.env.NEXT_PUBLIC_API_BASE_URL;

  client.setConfig({
    baseURL: baseURL,
  });
};
console.log("BASE URL:", baseURL);
configureClient();
