defprotocol Swoosh.Email.Recipient do
  @moduledoc """
  Recipient Protocol controls how data is formatted into an email recipient

  ## Deriving

  The protocol allows leveraging the Elixir's `@derive` feature to simplify protocol implementation
  in trivial cases. Accepted options are:

    * `:name` (optional)
    * `:address` (required)

  ## Example

      defmodule MyUser do
        @derive {Swoosh.Email.Recipient, name: :name, address: :email}
        defstruct [:name, :email, :other_props]
      end

  or with optional name...

      defmodule MySubscriber do
        @derive {Swoosh.Email.Recipient, address: :email}
        defstruct [:email, :preferences]
      end

  full implementation without deriving...

      defmodule MyUser do
        defstruct [:name, :email, :other_props]
      end

      defimpl Swoosh.Email.Recipient, for: MyUser do
        def format(%MyUser{name: name, email: address} = value) do
          {name, address}
        end
      end
  """

  @type t :: term
  @fallback_to_any true

  @doc """
  Formats `value` into a Swoosh recipient, a 2-tuple with recipient name and recipient address
  """
  @spec format(t) :: Swoosh.Email.mailbox()
  def format(value)
end

defimpl Swoosh.Email.Recipient, for: Any do
  defmacro __deriving__(module, struct, opts) do
    name_field = Keyword.get(opts, :name)
    address_field = Keyword.fetch!(opts, :address)

    fields =
      [
        if(name_field, do: {name_field, {:name, [generated: true], __MODULE__}}, else: nil),
        {address_field, {:address, [generated: true], __MODULE__}}
      ]
      |> Enum.reject(&is_nil/1)

    quote do
      defimpl Swoosh.Email.Recipient, for: unquote(module) do
        def format(%{unquote_splicing(fields)}) do
          {unquote(if(name_field, do: Macro.var(:name, __MODULE__), else: "")), address}
        end
      end
    end
  end

  def format(data) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: data,
      description: """
      Swoosh.Email.Recipient needs to be implemented
      """
  end
end
