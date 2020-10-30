defmodule Swoosh.Email.RecipientTest do
  use ExUnit.Case, async: true

  alias Swoosh.Email.Recipient

  defmodule Avenger do
    @derive {Recipient, name: :name, address: :email}
    defstruct [:name, :email]
  end

  defmodule Villian do
    @derive {Recipient, address: :email}
    defstruct [:we_dont_care_about_their_names, :email]
  end

  defmodule Minion do
    defstruct [:banana, :wulala]
  end

  defimpl Recipient, for: Minion do
    def format(%Minion{banana: email, wulala: w}) do
      {"Minion #{w}", email}
    end
  end

  test "derive both name and address" do
    assert Recipient.format(%Avenger{name: "Thor", email: "thor@avengers.org"}) ==
             {"Thor", "thor@avengers.org"}
  end

  test "derive address only" do
    assert Recipient.format(%Villian{
             we_dont_care_about_their_names: "Random Villian",
             email: "random@villain.me"
           }) == {"", "random@villain.me"}
  end

  test "full impl" do
    assert Recipient.format(%Minion{banana: "baabababa@minions.org", wulala: "www"}) ==
             {"Minion www", "baabababa@minions.org"}
  end
end
