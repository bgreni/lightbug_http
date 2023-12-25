from mojoweb.header import RequestHeader, ResponseHeader
from mojoweb.uri import URI
from mojoweb.args import Args
from mojoweb.stream import StreamReader
from mojoweb.body import Body, RequestBodyWriter, ResponseBodyWriter
from mojoweb.utils import Bytes, Duration, TCPAddr


struct Request:
    var header: RequestHeader
    var uri: URI

    var post_args: Args

    var body_stream: StreamReader
    var w: RequestBodyWriter
    var body: Body
    var body_raw: Bytes

    # TODO: var multipart_form
    # TODO: var multipart_form_boundary

    var parsed_uri: Bool
    # TODO: var parsed_post_args: Bool

    # TODO: var keep_body_buffer: Bool

    var server_is_tls: Bool

    var timeout: Duration

    # TODO: var use_host_header: Bool

    var disable_redirect_path_normalization: Bool

    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        post_args: Args,
        body: Bytes,
        server_is_tls: Bool,
        timeout: Duration,
        disable_redirect_path_normalization: Bool,
    ):
        self.header = header
        self.uri = uri
        self.post_args = post_args
        self.body_stream = StreamReader()
        self.w = RequestBodyWriter()
        self.body = Body()
        self.body_raw = body
        self.parsed_uri = False
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.disable_redirect_path_normalization = disable_redirect_path_normalization

    # assign parsed uri
    fn __init__(
        inout self,
        header: RequestHeader,
        uri: URI,
        post_args: Args,
        body: Bytes,
        parsed_uri: Bool,
        server_is_tls: Bool,
        timeout: Duration,
        disable_redirect_path_normalization: Bool,
    ):
        self.header = header
        self.uri = uri
        self.post_args = post_args
        self.body_stream = StreamReader()
        self.w = RequestBodyWriter()
        self.body = Body()
        self.body_raw = body
        self.parsed_uri = parsed_uri
        self.server_is_tls = server_is_tls
        self.timeout = timeout
        self.disable_redirect_path_normalization = disable_redirect_path_normalization

    fn host(self) -> String:
        return self.uri.host()

    fn set_host(self, host: String) -> Self:
        let new_uri = self.uri
        return Self(
            self.header,
            new_uri.set_host(host),
            self.post_args,
            self.body_raw,
            self.server_is_tls,
            self.timeout,
            self.disable_redirect_path_normalization,
        )

    fn set_host_bytes(self, host: Bytes) -> Self:
        let new_uri = self.uri
        return Self(
            self.header,
            new_uri.set_host_bytes(host),
            self.post_args,
            self.body_raw,
            self.server_is_tls,
            self.timeout,
            self.disable_redirect_path_normalization,
        )

    fn request_uri(self) -> String:
        if self.parsed_uri:
            self.set_request_uri_bytes(self.uri.request_uri())
        return self.header.request_uri()

    fn set_request_uri(self, request_uri: String) -> Self:
        let new_header = self.header
        return Self(
            new_header.set_request_uri(request_uri._buffer),
            self.uri,
            self.post_args,
            self.body_raw,
            False,
            self.server_is_tls,
            self.timeout,
            self.disable_redirect_path_normalization,
        )

    fn set_request_uri_bytes(self, request_uri: Bytes) -> Self:
        let new_header = self.header
        return Self(
            new_header.set_request_uri_bytes(request_uri),
            self.uri,
            self.post_args,
            self.body_raw,
            False,
            self.server_is_tls,
            self.timeout,
            self.disable_redirect_path_normalization,
        )

    fn connection_close(self) -> Bool:
        return self.header.connection_close()

    fn set_connection_close(self, connection_close: Bool) -> Self:
        let new_header = self.header
        return Self(
            new_header.set_connection_close(),
            self.uri,
            self.post_args,
            self.body_raw,
            self.parsed_uri,
            self.server_is_tls,
            self.timeout,
            self.disable_redirect_path_normalization,
        )


struct Response:
    var header: ResponseHeader

    var stream_immediate_header_flush: Bool
    var stream_body: Bool

    var body_stream: StreamReader
    var w: ResponseBodyWriter
    var body: Body
    var body_raw: Bytes

    var skip_reading_writing_body: Bool

    # TODO: var keep_body_buffer: Bool

    var raddr: TCPAddr
    var laddr: TCPAddr

    fn __init__(inout self, header: ResponseHeader, body: Bytes):
        self.header = header
        self.stream_immediate_header_flush = False
        self.stream_body = False
        self.body_stream = StreamReader()
        self.w = ResponseBodyWriter()
        self.body = Body()
        self.body_raw = body
        self.skip_reading_writing_body = False
        self.raddr = TCPAddr()
        self.laddr = TCPAddr()

    fn status_code(self) -> Int:
        return self.header.status_code()

    fn set_status_code(self, status_code: Int) -> Self:
        let new_header = self.header
        return Self(
            new_header.set_status_code(status_code),
            self.body_raw,
        )

    fn connection_close(self) -> Bool:
        return self.header.connection_close()

    fn set_connection_close(self, connection_close: Bool) -> Self:
        let new_header = self.header
        return Self(
            new_header.set_connection_close(),
            self.body_raw,
        )