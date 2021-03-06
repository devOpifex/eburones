#' Eburones
#' 
#' Session middleware.
#' 
#' @param identifier Function that creates a unique token.
#' This is run when creating a new session.
#' @param name Cookie name.
#' @param backend Storage class to keep track of callbacks.
#' @param callback Function to run when a callback is created or retrieved.
#' @param ... Passed to the `cookie` method of the [ambiorix::Response] class.
#' 
#' @importFrom ambiorix token_create
#' 
#' @export 
eburones <- function(
  ...,
  name = "session",
  backend = Local$new(),
  callback = \(req, res) list(),
  identifier = token_create
) {
  if(!is.function(callback))
    stop("`callback` must be a function")

  if(length(methods::formalArgs(callback)) != 2)
    stop("`callback` must accept 2 arguments: req, and res")

  \(req, res) {

    # user from cookie
    user <- req$cookie[[name]]

    # user found
    if(backend$has(user)) {
      req$session <- backend$get(user)
      obj <- callback(req, res)
      backend$set(user, obj)
      return(NULL)
    }

    # create new user
    token <- identifier()

    # set the user
    obj <- callback(req, res)

    backend$set(token, obj)
    req$session <- obj
    
    # set the cookie
    res$cookie(name, token, ...)

    return(NULL)
  }
}