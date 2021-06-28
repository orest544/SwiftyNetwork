![CI](https://github.com/orest544/SwiftyNetwork/workflows/CI/badge.svg)

# SwiftyNetwork

## Usage

- Create **data transfer service**

```swift
let dataTransferService: DataTransferService = {
    let server = Server(scheme: .https, host: "apple.com")
    let config = NetworkConfig(server: server)
    return DefaultDataTransferService(config: config)
}()
```

- Implement **data models** for request **body** and **response**

```swift
struct CredentialsBody: Encodable {
    let email: String
    let password: String
}
    
struct LoginResponse: Decodable {
    let accessToken: String
}
```

- Assemble the **endpoint** data structure

```swift
let credentials = CredentialsBody(email: "email@example.com", 
                                  password: "superpassword123")
                                  
let endpoint = Endpoint<LoginResponse>(path: "/api/login", 
                                       method: .post, 
                                       body: credentials)
```

- Perform a **request**

```swift
dataTransferService.request(with: endpoint) { result in
    switch result {
    case .success(let response):
        print(response.accessToken)
    case .failure(let error):
        print(error)
    }
}
```
