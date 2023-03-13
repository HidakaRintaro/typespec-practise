import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;

@service({
  title: "Swagger Petstore - OpenAPI 3.0",
  version: "1.0.11",
})
@doc("""
  This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
  Swagger at [https://swagger.io](https://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
  You can now help us improve the API whether it's by making changes to the definition itself or to the code.
  That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

  _If you're looking for the Swagger 2.0/OAS 2.0 version of Petstore, then click [here](https://editor.swagger.io/?url=https://petstore.swagger.io/v2/swagger.yaml). Alternatively, you can load via the `Edit > Load Petstore OAS 2.0` menu option!_

  Some useful links:
  - [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
  - [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)
""")
@server("https://petstore3.swagger.io/api/v3", "")
@useAuth(
  OAuth2Auth<[
    {
      type: OAuth2FlowType.implicit,
      authorizationUrl: "https://petstore3.swagger.io/oauth/authorize",
      // DOCS: https://github.com/microsoft/typespec/issues/1113
      // 説明文が追加できない問題
      scopes: ["write:pets", "read:pets"],
    }
  ]> | ApiKeyAuth<ApiKeyLocation.header, "api_key">
)
namespace TypeSpecSample;
namespace Auth {
  @tag("pet")
  @route("/pets")
  namespace PetAPI {
    interface Pets {
      @summary("Update an existing pet")
      @doc("Update an existing pet by Id")
      @put
      update(
        @header
        contentType: "application/json" | "application/xml" | "application/x-www-form-urlencoded",

        @doc("Update an existent pet in the store")
        @body
        pet: Pet
      ):
        | {
            @doc("Successful operation")
            @statusCode
            statusCode: 200;
            @header contentType: "application/json" | "application/xml";
            @body pet: Pet;
          }
        | {
            @doc("Invalid ID supplied")
            @statusCode
            statusCode: 400;
          }
        | {
            @doc("Pet not found")
            @statusCode
            statusCode: 404;
          }
        | {
            @doc("Validation exception")
            @statusCode
            statusCode: 405;
          };

      @summary("Add a new pet to the store")
      @doc("Add a new pet to the store")
      @post
      create(
        @header
        contentType: "application/json" | "application/xml" | "application/x-www-form-urlencoded",

        @doc("Create a new pet in the store")
        @body
        pet: Pet
      ): {
        @doc("Successful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json" | "application/xml";
        @body pet: Pet;
      } | {
        @doc("Invalid input")
        @statusCode
        statusCode: 405;
      };
    }

    @route("/findByStatus")
    interface FindByStatus {
      @summary("Finds Pets by status")
      @doc("Multiple status values can be provided with comma separated strings")
      @get
      list(
        @doc("Status values that need to be considered for filter")
        @query
        status?: "available" | "pending" | "sold"
      ): {
        @doc("successful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json" | "application/xml";
        @body pets: Pet[];
      } | {
        @doc("Invalid status value")
        @statusCode
        statusCode: 400;
      };
    }

    @route("/findByTags")
    interface FindByTags {
      @summary("Finds Pets by tags")
      @doc("Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.")
      @get
      list(
        @doc("Tags to filter by")
        @query
        tags?: string[]
      ): {
        @doc("successful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json" | "application/xml";
        @body pets: Pet[];
      } | {
        @doc("Invalid tag value")
        @statusCode
        statusCode: 400;
      };
    }

    @route("/{petId}")
    interface Details {
      @summary("Find pet by ID")
      @doc("Returns a single pet")
      @get
      read(
        @doc("ID of pet to return")
        @path
        petId: int64
      ): {
        @doc("successful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json" | "application/xml";
        @body pet: Pet;
      } | {
        @doc("Invalid ID supplied")
        @statusCode
        statusCode: 400;
      } | {
        @doc("Pet not found")
        @statusCode
        statusCode: 404;
      };

      @summary("Updates a pet in the store with form data")
      @post
      create(
        @doc("ID of pet that needs to be updated")
        @path
        petId: int64,

        @doc("Name of pet that needs to be updated")
        @query
        name?: string,

        @doc("Status of pet that needs to be updated")
        @query
        status?: string
      ): {
        @doc("Invalid input")
        @statusCode
        statusCode: 405;
      };

      @summary("Deletes a pet")
      @doc("delete a pet")
      @delete
      delete(
        @header api_key?: string,

        @doc("Pet id to delete")
        @path
        petId: int64
      ): {
        @doc("Invalid pet value")
        @statusCode
        statusCode: 400;
      };

      @summary("uploads an image")
      @route("/uploadImage")
      @post
      uploadImage(
        @doc("ID of pet to update")
        @path
        petId: int64,

        @doc("Additional Metadata")
        @query
        additionalMetadata?: string,
        @header contentType: "application/octet-stream",
        @body image: bytes
      ): {
        @doc("sucdcessful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json";
        @body apiResponse: ApiResponse;
      };
    }
  }

  @tag("store")
  @route("/store")
  namespace StoreAPI {
    interface Store {
      @summary("Returns pet inventories by status")
      @doc("Returns a map of status codes to quantities")
      @route("/inventory")
      @get
      read(): {
        @doc("successful operation")
        @statusCode
        statusCode: 200;
        @header contentType: "application/json";
        @body additionalProperties: Record<int32>;
      };
    }
  }
}

@tag("store")
@route("/store")
namespace StoreAPI {
  @route("/order")
  interface StoreOrder {
    @summary("Place an order for a pet")
    @doc("Place a new order in the store")
    @post
    create(
      @header
      contentType: "application/json" | "application/xml" | "application/x-www-form-urlencoded",
      @body order: Order
    ): {
      @doc("successful operation")
      @statusCode
      statusCode: 200;
      @header contentType: "application/json";
      @body order: Order;
    } | {
      @doc("Invalid input")
      @statusCode
      statusCode: 405;
    };
  }

  @route("/order/{orderId}")
  interface OrderDetails {
    @summary("Find purchase order by ID")
    @doc("For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.")
    @get
    read(
      @doc("IDof order that needs to be fetched")
      @path
      orderId: int64
    ): {
      @doc("successful operation")
      @statusCode
      statusCode: 200;
      @header contentType: "application/json" | "application/xml";
      @body order: Order;
    } | {
      @doc("Invalid ID supplied")
      @statusCode
      statusCode: 400;
    } | {
      @doc("Order not found")
      @statusCode
      statusCode: 404;
    };

    @summary("Delete purchase order by ID")
    @doc("For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors")
    @delete
    delete(
      @doc("ID of the order that needs to bedeleted")
      @path
      orderId: int64
    ): {
      @doc("Invalid IDsupplied")
      @statusCode
      statusCode: 400;
    } | {
      @doc("Order not found")
      @statusCode
      statusCode: 404;
    };
  }
}

@tag("user")
@route("/user")
namespace UserAPI {
  interface Users {
    @summary("Create user")
    @doc("This can only be done by the logged in user.")
    @post
    create(
      @header
      contentType: "application/json" | "application/xml" | "application/x-www-form-urlencoded",

      @doc("Created user object")
      @body
      user: User
    ): {
      @doc("successful operation")
      // NOTE: swaggerEditorではdefaultってなってるけど、defaultなんてコードねぇよ！
      @statusCode
      statusCode: 200;
      @header contentType: "application/json" | "application/xml";
      @body user: User;
    };

    @summary("Creates list of users with given input array")
    @doc("Creates list of users with given input array")
    @route("/createWithList")
    @post
    createWithList(
      @header contentType: "application/json",
      @body users: User[]
    ): {
      @doc("Successful operation")
      @statusCode
      statusCode: 200;
      @header contentType: "application/json" | "application/xml";
      @body user: User;
    };

    @summary("Logs user into the system")
    @route("/login")
    @get
    login(
      @doc("The user name for login")
      @query
      username?: string,

      @doc("The password for login in clear text")
      @query
      password?: string
    ): {
      @doc("successful operation")
      @statusCode
      statusCode: 200;
      // NOTE: 公式通りに指定するならこういう書き方じゃないの？？？
      // @header({
      //   contentType: "application/xml" | "application/json",

      //   @doc("calls per hour allowed by the user")
      //   `X-Rate-Limit`: int32,

      //   @doc("date in UTC when token expires")
      //   `X-Expires-After`: zonedDateTime,
      // })
      @header contentType: "application/xml" | "application/json";

      @body
      res: string;

      @doc("calls per hour allowed by the user")
      @header
      `X-Rate-Limit`: int32;

      @doc("date in UTC when token expires")
      @header
      `X-Expires-After`: zonedDateTime;
    } | {
      @doc("Invalid username/password supplied")
      @statusCode
      statusCode: 400;
    };

    @summary("Logs out current logged in user session")
    @route("/logout")
    @get
    logout(): {
      @doc("successful operation")
      // NOTE: swaggerEditorではdefaultってなってるけど、defaultなんてコードねぇよ！
      @statusCode
      statusCode: 200;
    };
  }

  @route("/{username}")
  interface FindByName {
    @summary("Get user by user name")
    @get
    read(
      @doc("The name that needs to be fetched. Use user1 for testing.")
      @path
      username: string
    ): {
      @doc("successful operation")
      @statusCode
      statusCode: 200;
      @header contentType: "application/json" | "application/xml";
      @body user: User;
    } | {
      @doc("Invalid username supplied")
      @statusCode
      statusCode: 400;
    } | {
      @doc("User not found")
      @statusCode
      statusCode: 404;
    };

    @summary("Update user")
    @doc("This can only be done by the logged in user.")
    @put
    update(
      @doc("name that need to be deleted")
      @path
      username: string,

      @header
      contentType: "application/json" | "application/xml" | "application/x-www-form-urlencoded",

      @doc("Update an existent user in the store")
      @body
      user: User
    ): {
      @doc("successful operation")
      // NOTE: swaggerEditorではdefaultってなってるけど、defaultなんてコードねぇよ！
      @statusCode
      statusCode: 200;
    };

    @summary("Delete user")
    @doc("This can only be done by the logged in user.")
    @delete
    delete(
      @doc("The name that needs to be deleted")
      @path
      username: string
    ): {
      @doc("Invalid username supplied")
      @statusCode
      statusCode: 400;
    } | {
      @doc("User not found")
      @statusCode
      statusCode: 404;
    };
  }
}

model Order {
  id?: int64;
  petId?: int64;
  quantity?: int32;
  shipDate?: zonedDateTime;

  @doc("Order Status")
  status?: "placed" | "approved" | "delivered";
  complete?: boolean;
}

model Customer {
  id?: int64;
  username: string;
  address?: Address[];
}

model Address {
  street?: string;
  city?: string;
  state?: string;
  zip?: string;
}

model Category {
  id?: int64;
  name?: string;
}

model User {
  id?: int64;
  username?: string;
  firstName?: string;
  lastName?: string;
  email?: string;
  password?: string;
  phone?: string;

  @doc("User Status")
  userStatus?: int32;
}

model Tag {
  id?: int64;
  name?: string;
}

model Pet {
  id?: int64;
  name: string;
  category?: Category;
  photoUrls: string[];
  tags?: Tag[];

  @doc("pet status in the store")
  status?: "available" | "pending" | "sold";
}

model ApiResponse {
  code?: int32;
  type?: string;
  message?: string;
}
