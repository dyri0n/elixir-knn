defmodule Knn.Util do
  # Función auxiliar para obtener entrada con un valor por defecto
  def get_input_with_default(prompt, default) do
    IO.puts("#{prompt}")

    input =
      IO.gets("(default \"#{default}\"): ")
      |> String.trim()

    if input == "" do
      default
    else
      input
    end
  end

  # Función auxiliar para obtener un entero con valor por defecto
  def get_input_integer_with_default(prompt, default) do
    IO.puts("#{prompt}")

    input =
      IO.gets("(default \"#{default}\"): ")
      |> String.trim()

    if input == "" do
      default
    else
      String.to_integer(input)
    end
  end

  # Función auxiliar para obtener un booleano con valor por defecto
  def get_input_boolean_with_default(prompt, default) do
    IO.puts("#{prompt}")

    input =
      IO.gets("(default \"#{default}\"): ")
      |> String.trim()
      |> String.downcase()

    if input == "" do
      default
    else
      to_boolean(input)
    end
  end

  # Función auxiliar para convertir "true" y "false" a booleanos
  def to_boolean("true"), do: true
  def to_boolean("false"), do: false

  # Función auxiliar para obtener una fecha con valor por defecto
  def get_input_date_with_default(prompt, default) do
    IO.puts("#{prompt}")

    input =
      IO.gets("(default \"#{default}\"): ")
      |> String.trim()

    if input == "" do
      default
    else
      Date.from_iso8601!(input)
    end
  end

  # Función auxiliar para obtener un float con valor por defecto
  def get_input_float_with_default(prompt, default) do
    IO.puts("#{prompt}")

    input =
      IO.gets("(default \"#{default}\"): ")
      |> String.trim()

    if input == "" do
      default
    else
      Float.parse(input) |> elem(0)
    end
  end
end
