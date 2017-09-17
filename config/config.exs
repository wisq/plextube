use Mix.Config

# Don't really need the Goon driver.  Signals are broken anyway.
config :porcelain,
  driver: Porcelain.Driver.Basic

if Mix.env != "test" && File.exists?("config/plextube.exs") do
  import_config "plextube.exs"
end
