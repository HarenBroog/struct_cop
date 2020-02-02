# StructCop

[![Build Status](https://travis-ci.org/HarenBroog/struct_cop.svg?branch=master)](https://travis-ci.org/HarenBroog/struct_cop.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/HarenBroog/struct_cop/badge.svg?branch=master)](https://coveralls.io/github/HarenBroog/struct_cop?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/struct_cop.svg)](https://hex.pm/packages/struct_cop)
[![Hex.pm](https://img.shields.io/hexpm/dt/struct_cop.svg)](https://hex.pm/packages/struct_cop)


StructCop is a library that was aimed to introduce **data correctness** and **type coercion** into Elixir structs. It also simplifies building valid structs with **smart constructors**.

## Getting Started

### Installation

Add `struct_cop`to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:struct_cop, "~> 0.2.0"}
  ]
end
```

### Contract
Define a contract for given entity. We will be describing a single measure for sport activity:

```elixir
defmodule Measurement do
  use StructCop

  contract do
    field :elevation, :float
    field :lat, :float
    field :lng, :float
    field :tracked_at, :utc_datetime_usec
  end

  def validate(changeset) do
    import Ecto.Changeset

    changeset
    |> validate_required([:tracked_at, :lat, :lng])
    |> validate_number(:lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:lng, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end
end
```
### Usage
From that moment we can:
```elixir
> Measurement.new!(lat: 10, lng: 20, tracked_at: DateTime.utc_now())
%Measurement{
  elevation: nil,
  lat: 10.0,
  lng: 20.0,
  tracked_at: ~U[2019-12-28 18:36:01.625656Z]
}
```
It also casts fields from binaries:
```elixir
> Measurement.new!(lat: "52.409538", lng: "16.931992", tracked_at: "2019-12-28T18:30:43.288080+00:00")
%Measurement{
  elevation: nil,
  lat: 52.409538,
  lng: 16.931992,
  tracked_at: ~U[2019-12-28 18:30:43.288080Z]
}
```
Passing invalid attributes raises an `ArgumentError`:
```elixir
> Measurement.new!(lat: "not_a_float", lng: 200.10)
** (ArgumentError) cast failed for %Measurement{elevation: nil, lat: nil, lng: nil, tracked_at: nil}:
params:
  %{"lat" => "not_a_float", "lng" => 200.1}
errors:
  [lng: {"must be less than or equal to %{number}", [validation: :number, kind: :less_than_or_equal_to, number: 180]}, tracked_at: {"can't be blank", [validation: :required]}, lat: {"is invalid", [type: :float, validation: :cast]}]

    (struct_cop) lib/struct_cop.ex:47: StructCop.cast!/2
```
## Credits
- [Tobiasz Małecki](https://github.com/amatalai) - discussing initial idea
- [Maciej Kaszubowski](https://github.com/mkaszubowski) - discussing initial idea
