import rpweibo
import pyotherside

def getToken(API_KEY,API_SECRET,REDIRECT_URI,username,password):
    example_app = rpweibo.Application(API_KEY, API_SECRET, REDIRECT_URI)
    weibo = rpweibo.Weibo(example_app)
    authenticator = rpweibo.UserPassAutheticator(username, password)
    access_token = authenticator.auth(example_app)
    print(access_token)
    pyotherside.send("pyhandle",access_token)
