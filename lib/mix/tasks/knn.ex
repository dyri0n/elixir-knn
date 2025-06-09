defmodule Mix.Tasks.Knn do
  use Mix.Task

  @shortdoc "Ejecuta la predicción KNN desde consola"

  def run(_args) do
    Mix.Task.run("app.start")
    Knn.CLI.main()
  end
end
