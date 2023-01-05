- [ ] Rename `model_class` to include `super_spreader`
- [ ] Either combine the fake models or use a real ActiveRecord class
- [ ] Ensure Redis is set up

    if [ -v REDIS_URL ]; then
      echo "✅ REDIS_URL is set to: $REDIS_URL"
    else
      echo "❌ Please ensure Redis is installed and set REDIS_URL"
      exit 1
    fi

- [ ] Test against Ruby 3
- [ ] Test against Rails 7
