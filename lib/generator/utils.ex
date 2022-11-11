defmodule Utils do
  @moduledoc """
  Random utils
  """

  alias Generator.Plans.Plan

  def first_subscription_billing_date() do
    Timex.today()
    |> Timex.shift(months: +1)
    |> Timex.beginning_of_month()
  end

  def prorate_subscription_amount(%Plan{price_monthly: price_monthly}) do
    today = Timex.today()
    days_in_current_month = Timex.days_in_month(today)
    price_for_one_day = Decimal.div(price_monthly, decimal(days_in_current_month))
    days_left_in_month = days_in_current_month - today.day

    Decimal.mult(decimal(days_left_in_month), price_for_one_day)
    |> dec_round()
  end

  def decimal(number \\ zero()) do
    Decimal.new(number)
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
end
