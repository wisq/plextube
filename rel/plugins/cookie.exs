# Kinda ugly, but this is the best way I can provide a
# reasonable configuration example without either exposing
# my cookies, and/or having everyone use the same ones.

defmodule Cookie do
  def get(env) do
    file = ".cookie.#{env}"
    get_or_create(File.exists?(file), file)
  end

  defp get_or_create(true, file) do
    file
    |> File.read!
    |> String.trim
    |> String.to_atom
  end

  defp get_or_create(false, file) do
    cookie = Distillery.Cookies.get
             |> Atom.to_string
    File.write!(file, cookie)
    IO.puts "Stored new deploy cookie in #{file}"
    get_or_create(true, file)
  end
end
