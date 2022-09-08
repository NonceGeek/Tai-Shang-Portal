defmodule SuperIssuer.Nft.Parser do

    def parse_token_uri(payload_raw) do
      %{image: img_raw} =
        payload =
          URIHandler.decode_uri(payload_raw)
      img_parsed =
        URIHandler.decode_uri(img_raw)
      %{payload: payload, img_parsed: img_parsed}
    end

    def parse_token_uri(payload_raw, :external_link) do
      %{image: image} =
        payload =
          URIHandler.decode_uri(payload_raw)
      %{payload: payload, img_parsed: image}
    end
  end
