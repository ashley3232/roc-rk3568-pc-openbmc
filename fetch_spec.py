#!/usr/bin/env python3
"""Download and parse ROC-RK3568-PC board specification PDF."""

from coze_coding_dev_sdk.fetch import FetchClient
from coze_coding_utils.runtime_ctx.context import Context

def main():
    # PDF URL from user
    url = "https://coze-coding-project.tos.coze.site/create_attachment/2026-05-26/3590319425463436_3f53b6fe603f5d60bff795596ae9c5e2_ROC-RK3568-PC-%E5%BC%80%E6%BA%90%E4%B8%BB%E6%9D%BF-%E8%A7%84%E6%A0%BC%E4%B9%A6.pdf?sign=4901854486-e234c81b81-0-5b9ae88b28c62d0d4bb1f276d813c71a39b6a84b9d257ec57377ad2daeb6bb82"
    
    client = FetchClient()
    
    print(f"Fetching URL: {url}")
    response = client.fetch(url=url)
    
    print(f"Status Code: {response.status_code}")
    print(f"Status Message: {response.status_message}")
    print(f"Title: {response.title}")
    print(f"File Type: {response.filetype}")
    print(f"URL: {response.url}")
    
    # Extract text content
    text_content = []
    for item in response.content:
        if item.type == "text":
            text_content.append(item.text)
    
    print("\n--- Text Content ---")
    for i, text in enumerate(text_content):
        print(f"[{i+1}] {text}")
    
    # Save content to file
    with open("/workspace/projects/hardware_spec.txt", "w", encoding="utf-8") as f:
        f.write(f"Title: {response.title}\n\n")
        f.write("\n".join(text_content))
    
    print("\nContent saved to /workspace/projects/hardware_spec.txt")

if __name__ == "__main__":
    main()
