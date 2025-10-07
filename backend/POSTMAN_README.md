Import & run (Postman)

1. Start the backend with H2 profile:

```bash
./gradlew bootRun --args='--spring.profiles.active=h2'
```

2. Open Postman -> Import -> choose `postman_collection.json` and `postman_environment.json`.
3. Select the environment `Demo Local` (baseUrl=http://localhost:8080).
4. Run the requests in the collection. `Get All Articles` should return the sample row.

Notes:
- To test with your MySQL, stop the app and run without the `h2` profile (ensure `application.properties` contains correct MySQL credentials).
- The collection uses the `{{baseUrl}}` environment variable so you can switch host or port easily.
