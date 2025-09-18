#!/bin/bash

API_BASE="https://umun4f7sqc.execute-api.us-east-1.amazonaws.com/prod"

echo "🚀 API 测试开始..."
echo "===================="

echo "1️⃣ 健康检查:"
curl -s "$API_BASE/" 
echo -e "\n"

echo "2️⃣ 获取所有笔记:"
curl -s "$API_BASE/notes" | jq
echo -e "\n"

echo "3️⃣ 创建新笔记:"
curl -s -X POST "$API_BASE/notes" \
  -H "Content-Type: application/json" \
  -d '{"title":"API测试笔记","content":"通过脚本创建的笔记"}' | jq
echo -e "\n"

echo "4️⃣ 再次获取笔记:"
curl -s "$API_BASE/notes" | jq
echo -e "\n"

echo "5️⃣ GitHub个人信息:"
curl -s "$API_BASE/github/profile" | jq '.login, .public_repos, .followers'
echo -e "\n"

echo "✅ API 测试完成!"
