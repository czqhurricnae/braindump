def application(environ, start_response):
    write = start_response("200 OK", [("Content-type", "text/plain")])
    write("Hello")
    return [" world!"]


if __name__ == "__main__":
    from wsgiref.simple_server import make_server
    server = make_server("localhost", 8080, application)
    server.serve_forever()
