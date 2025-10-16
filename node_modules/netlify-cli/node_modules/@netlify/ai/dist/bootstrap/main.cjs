"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/bootstrap/main.ts
var main_exports = {};
__export(main_exports, {
  fetchAIGatewayToken: () => fetchAIGatewayToken,
  fetchAIProviders: () => fetchAIProviders,
  parseAIGatewayContext: () => parseAIGatewayContext,
  setupAIGateway: () => setupAIGateway
});
module.exports = __toCommonJS(main_exports);
var isValidTokenResponse = (data) => {
  return typeof data === "object" && data !== null && typeof data.token === "string" && typeof data.url === "string";
};
var isValidProvidersResponse = (data) => {
  return typeof data === "object" && data !== null && typeof data.providers === "object" && data.providers !== null;
};
var fetchAIProviders = async ({ api }) => {
  try {
    if (!api.accessToken) {
      return [];
    }
    const url = `${api.scheme}://${api.host}/api/v1/ai-gateway/providers`;
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${api.accessToken}`,
        "Content-Type": "application/json"
      }
    });
    if (!response.ok) {
      if (response.status === 404) {
        return [];
      }
      throw new Error(`HTTP ${String(response.status)}: ${response.statusText}`);
    }
    const data = await response.json();
    if (!isValidProvidersResponse(data)) {
      throw new Error("Invalid providers response format");
    }
    const envVars = [];
    for (const provider of Object.values(data.providers)) {
      envVars.push({
        key: provider.token_env_var,
        url: provider.url_env_var
      });
    }
    return envVars;
  } catch (error) {
    console.warn(`Failed to fetch AI providers: ${error instanceof Error ? error.message : String(error)}`);
    return [];
  }
};
var fetchAIGatewayToken = async ({
  api,
  siteId
}) => {
  try {
    if (!api.accessToken) {
      return null;
    }
    const url = `${api.scheme}://${api.host}/api/v1/sites/${siteId}/ai-gateway/token`;
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${api.accessToken}`,
        "Content-Type": "application/json"
      }
    });
    if (!response.ok) {
      if (response.status === 404) {
        return null;
      }
      throw new Error(`HTTP ${String(response.status)}: ${response.statusText}`);
    }
    const data = await response.json();
    if (!isValidTokenResponse(data)) {
      throw new Error("Invalid response: missing token or url");
    }
    return {
      token: data.token,
      url: data.url
    };
  } catch (error) {
    console.warn(
      `Failed to fetch AI Gateway token for site ${siteId}: ${error instanceof Error ? error.message : String(error)}`
    );
    return null;
  }
};
var setupAIGateway = async (config) => {
  const { api, env, siteID, siteURL } = config;
  if (siteID && siteID !== "unlinked" && siteURL) {
    const [aiGatewayToken, envVars] = await Promise.all([
      fetchAIGatewayToken({ api, siteId: siteID }),
      fetchAIProviders({ api })
    ]);
    if (aiGatewayToken) {
      const aiGatewayContext = JSON.stringify({
        token: aiGatewayToken.token,
        url: `${siteURL}/.netlify/ai`,
        envVars
      });
      const base64Context = Buffer.from(aiGatewayContext).toString("base64");
      env.AI_GATEWAY = { sources: ["internal"], value: base64Context };
    }
  }
};
var parseAIGatewayContext = (aiGatewayValue) => {
  try {
    if (aiGatewayValue) {
      const decodedContext = Buffer.from(aiGatewayValue, "base64").toString("utf8");
      const aiGatewayContext = JSON.parse(decodedContext);
      return aiGatewayContext;
    }
  } catch {
  }
  return void 0;
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  fetchAIGatewayToken,
  fetchAIProviders,
  parseAIGatewayContext,
  setupAIGateway
});
//# sourceMappingURL=main.cjs.map