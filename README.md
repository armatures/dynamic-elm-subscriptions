# dynamic-elm-subscriptions
How do dynamic subscriptions work in Elm? Do they work when changing the url with `Nav.pushUrl`?]

This is a clone of [the Elm guide's Navigation example](https://guide.elm-lang.org/webapps/navigation.html) with the addition of a subscription function that is only set up for one of the routes.

Start elm-reactor with `yarn start`: you can then change the route by clicking on the links in the page. If you click the `keyboard` link, the app starts listening to key presses. The problem is, subscriptions don't look like they're updating.
