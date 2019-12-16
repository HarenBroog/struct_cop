# Use cases

Sometimes, especially in non-**CRUD** domains the user actions cannot be directly mapped into the database entities along with their changesets.  But still, from a frontend perspective they should be perceived as a whole. One typical example of such action, can be a registration process. It can be represented like this:

```elixir
defmodule RegisterUser do
  use StructCop

  @email_regex ~r/./

  contract do
    field :id, :binary_id
    field :email, :string
    field :password, :string
    field :first_name, :string
    field :last_name, :string
  end

  @impl StructCop
  def validate(changeset) do
    import Ecto.Changeset

    changeset
    |> validate_required([:id, :email, :password, :first_name, :last_name])
    |> validate_format(:email, @email_regex)
    |> validate_length(:password, min: 8, max: 72)
  end

  def call(attrs) do
    attrs
    |> new!()
    |> do_call()
  end

  defp do_call(%__MODULE__{} = cmd) do
    # do stuff with coerced struct
  end
end

```

Having this, allow us to keep a clear boundary between implementation details and things which depend on this module. Interface is overt and informative, a reader can check out contract definition for allowed fields and validations or just get an error message provided by `new!/1` function.

Moreover, this aproach promotes **fail fast** philisophy. Fields in contracts are validated and in contrast to ordinary structs coerced into proper types. Code which uses structs constructed with StructCop, can safely assume that certain fields will have certain shape.

No more checking if a binary is really a binary, manually converting `"4"` into an integer or what even worse, casting `"2019-12-09T20:57:40.429625+00:00"` into a `%DateTime{}`!
