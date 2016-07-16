# Template Server

A web server built using [Embla](https://pub.dartlang.org/packages/embla).

# Create user:
Make POST request on server_url_base/user with post params as url encoded:<br>
<b>'email'</b> : user uniaue email<br>
<b>'password'</b> : user password

# Login user:
Make POST request on server_url_base/login with post params as url encoded:<br>
<b>'username'</b> : valid user email <br>
<b>'password'</b> : user pass <br>
Next step is get response with HTTP_OK(200) and save header: <b>authorization</b>.<br>
The authorization header used for the interaction with server.
