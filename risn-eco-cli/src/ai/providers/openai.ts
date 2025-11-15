import fetch from "node-fetch";
const OPENAI_API = "https://api.openai.com/v1";

export async function embedText(text: string, apiKey: string) {
  const res = await fetch(`${OPENAI_API}/embeddings`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model: "text-embedding-3-small", input: text })
  });
  const json: any = await res.json();
  return json.data?.[0]?.embedding as number[];
}

export async function visionCaption(imageUrl: string, apiKey: string) {
  const res = await fetch(`${OPENAI_API}/chat/completions`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a fashion analyst." },
        { role: "user", content: [{ type: "text", text: "Describe this outfit with style tags." }, { type: "image_url", image_url: { url: imageUrl } }] as any }
      ],
      max_tokens: 150
    })
  });
  const json: any = await res.json();
  return json.choices?.[0]?.message?.content || "";
}
