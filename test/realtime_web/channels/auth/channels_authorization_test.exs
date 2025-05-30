defmodule RealtimeWeb.ChannelsAuthorizationTest do
  # async: false due to usage of mocks
  use ExUnit.Case, async: false

  import Mock
  import Generators

  alias RealtimeWeb.ChannelsAuthorization
  alias RealtimeWeb.JwtVerification

  @secret ""
  describe "authorize_conn/3" do
    test "when token is authorized" do
      input_token = "\n token %20 1 %20 2 %20 3   "
      expected_token = "token123"

      with_mock JwtVerification,
        verify: fn token, @secret, _jwks ->
          assert token == expected_token
          {:ok, %{}}
        end do
        assert {:ok, %{}} = ChannelsAuthorization.authorize(input_token, @secret, nil)
      end
    end

    test "when token is unauthorized" do
      with_mock JwtVerification, verify: fn _token, _secret, _jwks -> :error end do
        assert :error = ChannelsAuthorization.authorize("bad_token", @secret, nil)
      end
    end

    test "when token is not a string" do
      assert {:error, :invalid_token} = ChannelsAuthorization.authorize([], @secret, nil)
    end

    test "authorize_conn/3 fails when has missing headers" do
      jwt = generate_jwt_token(@secret, %{})

      assert {:error, :missing_claims} =
               ChannelsAuthorization.authorize_conn(jwt, @secret, nil)
    end
  end
end
