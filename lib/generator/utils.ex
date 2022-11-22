defmodule Utils do
  @moduledoc """
  Random utils
  """

  alias Generator.Plans.Plan

  require Logger

  def first_subscription_billing_date() do
    Timex.today()
    |> Timex.shift(months: +1)
    |> Timex.beginning_of_month()
  end

  def prorate_subscription_amount(%Plan{price: price, type: :monthly}) do
    today = Timex.today()
    days_in_current_month = Timex.days_in_month(today)
    price_for_one_day = Decimal.div(price, to_decimal(days_in_current_month))
    days_left_in_month = days_in_current_month - today.day

    Decimal.mult(to_decimal(days_left_in_month), price_for_one_day)
    |> dec_round()
  end

  def prorate_subscription_amount(%Plan{price: price, type: :yearly}) do
    today = Timex.today()

    days_left_in_year =
      today
      |> Timex.end_of_year()
      |> Timex.diff(today, :days)

    price_for_one_day = Decimal.div(to_decimal(price), to_decimal(365))

    Decimal.mult(to_decimal(days_left_in_year), to_decimal(price_for_one_day))
    |> dec_round()
  end

  @doc """
  Converts the passed value to a `Decimal`. Can handle integers, floats, strings, Decimals
  and `nil`. `nil` will default to `Decimal.new(0)`.
  """
  def to_decimal(value, default \\ zero())
  def to_decimal(nil, default), do: default
  def to_decimal("", default), do: default
  def to_decimal(binary, _default) when is_binary(binary), do: Decimal.new(binary)
  def to_decimal(int, _default) when is_integer(int), do: Decimal.new(int)
  def to_decimal(float, _default) when is_float(float), do: float |> to_string() |> to_decimal()
  def to_decimal(decimal = %Decimal{}, _default), do: decimal

  def to_decimal(other, default) do
    Logger.error("Got unexpected value to cast to a Decimal: #{inspect(other, pretty: true)}")
    default
  end

  def zero(), do: Decimal.new("0")
  def dec_round(number, amount \\ 2), do: Decimal.round(number, amount)

  def first_day_of_last_month() do
    Timex.today()
    |> Timex.shift(months: -1)
    |> Timex.beginning_of_month()
  end

  def last_day_of_last_month() do
    Timex.today()
    |> Timex.shift(months: -1)
    |> Timex.end_of_month()
  end

  def format_timestamp(timestamp) when is_binary(timestamp) do
    timestamp
    |> Timex.parse!("{ISO:Extended}")
    |> format_timestamp()
  end

  def format_timestamp(timestamp) do
    timestamp
    |> Timex.from_now()
  end

  @alphabet_lower_case [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  ]

  def generate_random_salt() do
    alphabet_upper_case =
      Enum.into(@alphabet_lower_case, [], fn letter -> String.upcase(letter) end)

    numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    Enum.reduce(1..8, "", fn _, acc ->
      case Enum.random([1, 2, 3]) do
        1 ->
          acc <> Enum.random(@alphabet_lower_case)

        2 ->
          acc <> Enum.random(alphabet_upper_case)

        3 ->
          acc <> to_string(Enum.random(numbers))
      end
    end)
  end
end
