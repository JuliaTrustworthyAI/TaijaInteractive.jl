# Layers Responsibility Separation

### Routing Layer

#### Responsibilities

- Define routes and map them to controller actions.
- Extract data from requests (URL parameters, query parameters, payload data).
- Prepare and return responses. ?

#### Input

- HTTP requests containing URL paths and methods.

#### Output

- Calls to controller functions, passing along any rData extracted from HTTP requests (e.g., body, headers).

### Controllers Layer

#### Responsibilities

- Handle application logic for each route.
- Call model functions to perform data operations.

#### Input

- Route and payload passed as function parameters by the routing layer.

#### Output

- JSON responses (or other formats) to be sent back to the client.
- Calls to model functions with extracted and validated data.

### Models Layer (CRUD Opeations)

#### Responsibilities

- Handle data operations and interactions with the database.
- Define and enforce data structures and relationships.
- Perform CRUD operations and other data-related logic.

#### Input

- Data and parameters passed from the controllers.
- SQL queries and database operations.

#### Output

- Data retrieved from or affected by database operations.
- Returns data structures (e.g., dictionaries, arrays) to controllers.

# Naming Convention

In any project, naming conventions play a crucial role in maintaining a clean and readable codebase. Here’s a set of naming conventions for a project our current project, based on preference of the team and Julia’s community standards.

### Summary of General Naming Conventions

1. **File Names:**
    - JS and HTML: Use kebab-case, e.g., main.js, index.html.
    - Julia: Use PascalCase
2. **Folder Names:**
    - Use flat-case, e.g., modelcontroller
3. **Function Names:**
    - JS and Julia: Use camelCase, e.g., fetchPosts(), createPost().
4. **Variable Names:**
    - JS and Julia: Use camelCase, e.g., postId, newPost.
    - HTML: Use hypthens, e.g., post-model, button-create.
5. **Module Names:**
    - JS and Julia: Use PascalCase, e.g., PostManager.
