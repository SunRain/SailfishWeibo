import rpweibo
import pyotherside
def getToken(API_KEY,API_SECRET,REDIRECT_URI,username,password):
    example_app = rpweibo.Application(API_KEY, API_SECRET, REDIRECT_URI)
    weibo = rpweibo.Weibo(example_app)
    authenticator = rpweibo.UserPassAutheticator(username, password)
    try:
        weibo.auth(authenticator)
        access_token = authenticator.auth(example_app)
        print(access_token)
        pyotherside.send("pyhandle",access_token)
    except rpweibo.AuthorizeFailed:
        print("Invalid username or password!")
        pyotherside.send("pyhandle","Error")
