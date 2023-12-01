# Decidim::Apifiles

This module adds capabilities to the Decidim API to upload and manage file blobs
that can be attached to different API objects through mutations.

## Usage

This is a backend development module aimed for developers. There is no user
interface or other functionality provided by this module.

The module provides a new API endpoint `/api/blobs` which can be used to upload
new file blobs to Decidim. These blobs can be then attached to different API
objects through mutations.

The blobs have to be uploaded as signed in. Sign in can be performed through the
`/api/sign_in` endpoint provided by the
[API Auth module](https://github.com/mainio/decidim-module-apiauth). The flow
should be as follows:

1. Sign in through `POST /api/sign_in`
2. Upload the file through `POST /api/blobs`
3. Perform any other API operations normally (e.g. GraphQL mutations)
4. Sign out through `DELETE /api/sign_out`

Example implementations can be found from the `examples` directory which perform
this whole flow. Examples are provided for Ruby and Node.js.

## Installation

Add the following lines to your application's Gemfile:

```ruby
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "main"
gem "decidim-apifiles", github: "mainio/decidim-module-apifiles", branch: "main"
```

And then execute:

```bash
bundle
```

And also follow the installation instructions of the
[API Auth module](https://github.com/mainio/decidim-module-apiauth).

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
