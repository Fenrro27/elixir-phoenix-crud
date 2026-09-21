defmodule ShopWeb.LiveViewCase do
  @moduledoc """
  This module defines the setup for testing LiveViews.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use ShopWeb.ConnCase
      import Phoenix.LiveViewTest
      use ShopWeb, :verified_routes
    end
  end
end
