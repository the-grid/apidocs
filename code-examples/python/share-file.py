# Command-line example for sharing files, including text, images etc

import os, sys, uuid, mimetypes

import requests
from requests_oauthlib import OAuth2Session
import flask

 
def debug(*things):
    string = ' '.join(str(t) for t in things)
    sys.stderr.write(string+'\n')

# Note: No error handling
class TheGridAuth:
    authorization_url = "https://passport.thegrid.io/login/authorize"
    token_url = "https://passport.thegrid.io/login/authorize/token"
    redirect_uri = 'http://localhost:3000/authenticated'

    def __init__(self, _id, _secret, scopes=[]):
        self.app_id = _id
        self.app_secret = _secret
        self.scopes = scopes

        self.flask = flask.Flask(__name__)
        # FIXME: implement loading token from disk
        self.session = OAuth2Session(self.app_id, scope=self.scopes, redirect_uri=self.redirect_uri)

        @self.flask.route("/authenticated", methods=["GET"])
        def callback():
            url = flask.request.url

            token = self.session.fetch_token(self.token_url,
                   client_secret=self.app_secret,
                   authorization_response=url)
            debug('/authenticated', 'got token')

            try:
                self.on_authenticated(self, token)
            except Exception, e:
                debug('ERROR', e)
                return e

             # FIXME: implement persistence of token to disk
            return 'Authenticated, go back to program'

    # Callback fired when we have been authicated
    def on_authenticated(self, token):
        print "%s Subclass or override this handler" % (__name__,)

    def authenticate(self, *args, **kwargs):
        authorization_url, state = self.session.authorization_url(self.authorization_url)
        print "Open in browser to authenticate:\n %s" % (authorization_url,)

        kwargs['port'] = 3000
        self.flask.run(*args, **kwargs)

 
if __name__ == "__main__":
    # Allow to use plain HTTP callback. Do not use on a production server
    os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'
    os.environ['OAUTHLIB_RELAX_TOKEN_SCOPE'] = '1' # workaround for https://github.com/idan/oauthlib/pull/323

    # !! Get these by registering an app at https://passport.thegrid.io
    app_id = os.environ.get('THEGRID_APP_ID') or ""
    app_secret = os.environ.get('THEGRID_APP_SECRET') or ""
    scopes = ["content_management", "update_profile"]
    auth = TheGridAuth(app_id, app_secret, scopes)

    filepath = sys.argv[1]
    filename = os.path.basename(filepath)
    mimetype = mimetypes.guess_type(filename)[0]
    files = {
        'content': (filename, open(filepath, 'rb'), mimetype),
        'type': mimetype,
        'url': 'content://'+str(uuid.uuid4())
    }
    def upload_file(auth, token):
        print 'Sharing file of type %s: %s' % (mimetype, filepath)
        r = auth.session.post("https://api.thegrid.io/share", files=files)
        if r.status_code == 202:
            job = 'https://api.thegrid.io'+r.headers['location']
            print 'Success: %s' % (job,)
            r = auth.session.get(job)
            print 'Job details: \n%s' % (r.content,)
        else:
            sys.stderr.write('ERROR: %s\n %s\n' % (r.status_code, r.content))

    auth.on_authenticated = upload_file
    auth.authenticate()



