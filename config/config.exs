use Mix.Config

# Don't really need the Goon driver.  Signals are broken anyway.
config :porcelain,
  driver: Porcelain.Driver.Basic

import_config "#{Mix.env}.exs"
