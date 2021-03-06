defmodule Ar2ecto.LineTest do
  use ExUnit.Case
  alias Ar2ecto.Line, as: L

  test "tokenize :defmodule" do
    assert L.tokenize("  class CreateUsers < ActiveRecord::Migration  ") == %{type: :defmodule, name: "CreateUsers"}
  end

  test "tokenize :up" do
    assert L.tokenize("  def self.up  ") == %{type: :up}
  end

  test "tokenize :down" do
    assert L.tokenize("  def self.down  ") == %{type: :down}
  end

  test "tokenize :change" do
    assert L.tokenize("  def self.change  ") == %{type: :change}
  end

  test "tokenize :create_table" do
    assert L.tokenize("create_table \"users\", :force => true do |t|") == %{type: :create_table, name: :users}
    assert L.tokenize("create_table \"peoples\" do |xxx|") == %{type: :create_table, name: :peoples}
    assert L.tokenize("create_table :peeps do |xxx|") == %{type: :create_table, name: :peeps}
  end

  test "tokenize :drop_table" do
    assert L.tokenize("drop_table \"users\"") == %{type: :drop_table, name: :users}
    assert L.tokenize("drop_table :peeps") == %{type: :drop_table, name: :peeps}
  end

  test "tokenize :add_field" do
    assert L.tokenize("t.datetime :created_at") == %{type: :add_field, name: :created_at, format: :datetime}
    assert L.tokenize("t.string :type") == %{type: :add_field, name: :type, format: :string}
    assert L.tokenize("t.integer :destroyed_by") == %{type: :add_field, name: :destroyed_by, format: :integer}
  end

  test "tokenize :add_field extrac params" do
    assert L.tokenize("t.string   :crypted_password, :limit => 40") == %{type: :add_field, name: :crypted_password, format: :string}
  end

  test "tokenize :add_field handle spaces" do
    assert L.tokenize("   t.string   :email  ") == %{type: :add_field, name: :email, format: :string}
  end

  test "tokenize :end" do
    assert L.tokenize("end") == %{type: :end, line: "end"}
    assert L.tokenize("  end") == %{type: :end, line: "  end"}
  end

  test "tokenize :timestamps" do
    assert L.tokenize("  timestamps ") == %{type: :timestamps}
  end

  test "tokenize :unknown" do
    assert L.tokenize("xxx") == %{type: :unknown, line: "xxx"}
  end

  test "tokenize nil" do
    assert L.tokenize(nil) == %{type: :unknown, line: nil}
  end

  test "render :defmodule" do
    actual = "class CreateUsers < ActiveRecord::Migration" |> L.tokenize |> L.render("MyApp")
    assert actual == "defmodule MyApp.Repo.Migrations.CreateUsers do\n  use Ecto.Migration"
  end

  test "render :up" do
    actual = "def self.up" |> L.tokenize |> L.render("MyApp")
    assert actual == "  def up do"
  end

  test "render :down" do
    actual = "def self.down" |> L.tokenize |> L.render("MyApp")
    assert actual == "  def down do"
  end

  test "render :change" do
    actual = "def self.change" |> L.tokenize |> L.render("MyApp")
    assert actual == "  def change do"
  end

  test "render :create_table" do
    actual = "create_table :paydays do |xxx|" |> L.tokenize |> L.render("MyApp")
    assert actual == "    create table(:paydays) do"
  end

  test "render :drop_table" do
    actual = "drop_table :paydays" |> L.tokenize |> L.render("MyApp")
    assert actual == "    drop table(:paydays)"
  end

  test "render :timestamps" do
    actual = "timestamps" |> L.tokenize |> L.render("MyApp")
    assert actual == "      timestamps"
  end

  test "render :add_field" do
    actual = "t.datetime :created_at" |> L.tokenize |> L.render("MyApp")
    assert actual == "      add :created_at, :datetime"
  end

  test "render :end" do
    actual = "  end" |> L.tokenize |> L.render("MyApp")
    assert actual == "  end"
  end

  test "render :unknown" do
    actual = "xxx" |> L.tokenize |> L.render("MyApp")
    assert actual == "xxx"
  end

end