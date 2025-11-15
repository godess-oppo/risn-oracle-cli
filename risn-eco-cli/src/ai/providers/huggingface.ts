import fetch from "node-fetch";

export async function hfEmbed(text: string, apiKey: string) {
  const res = await fetch("https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2", {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ inputs: text, options: { wait_for_model: true } })
  });
  const json: any = await res.json();
  return json as number[];
}
