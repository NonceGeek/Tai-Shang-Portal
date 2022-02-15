defmodule DIDWallet.CredentialHandler do
  def render(
    %{
      cpt_id: cpt_id,
      claim: claim,
      signers: signers
      } = credential, style) do
      do_render(claim, cpt_id, signers, style)
  end

  def do_render(claim, cpt_id, signers, style) do
    cpt_id                     # 根据 cpt id
    |> find_template()         # 找到数据库中的对应模板
    |> modify_by_style(style)  # 根据风格对模板进行优化
    |> input_claim(claim)      # 填入 claim
    |> input_signers(signers)  # 填入签名人
  end
end
