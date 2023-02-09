- [ ] Rename `model_class` to include the words `super_spreader` for clarity
- [ ] Ensure Redis is set up

    if [ -v REDIS_URL ]; then
      echo "✅ REDIS_URL is set to: $REDIS_URL"
    else
      echo "❌ Please ensure Redis is installed and set REDIS_URL"
      exit 1
    fi

- [ ] Test against Rails 7
