defmodule SuperIssuer.Ethereum.ABI do
  alias SuperIssuer.Ethereum.{Function, Event, Argument}

  @abi_type %{event: "event", function: "function"}

  def get_events(abi) do
    abi
    |> StructTranslater.to_atom_struct()
    |> Enum.filter(fn %{type: type} ->
      type == @abi_type.event
    end)
    |> Enum.map(fn ele ->
      %Event{
        name: ele.name,
        args:
          ele.inputs
          |> Enum.map(&%Argument{name: &1.name, type: :"#{&1.type}", indexed: &1.indexed})
      }
    end)
  end

  def decode_input(input, abi) do
    {sig_str, params} =  String.split_at(input, 10)
    %{signature: signature} = find_func_by_abi(sig_str, abi)
    %{
      func: signature,
      params: ABI.decode(signature, Base.decode16!(params,case: :lower))
    }
  end

  def find_func_by_abi(sig_str, abi) do
    funcs = get_funcs(abi)
    Enum.find(funcs, fn %{signature_bytes: signature_bytes} ->
      signature_bytes == sig_str
    end)
  end

  def get_funcs(abi) do
    abi
    |> StructTranslater.to_atom_struct()
    |> Enum.filter(fn %{type: type} ->
      type == @abi_type.function
    end)
    |> Enum.map(fn ele ->
    inputs =  ele.inputs |> Enum.map(&%Argument{name: &1.name, type: :"#{&1.type}"})
    %Function{
        name: ele.name,
        inputs: inputs,
        outputs:
          ele.outputs |> Enum.map(&%Argument{name: &1.name, type: :"#{&1.type}"}),
        signature_bytes:
          Function.gen_sig_bytes(ele.name, inputs),
        signature:
          gen_sig(ele.name, inputs)
      }
    end)
  end

  def find_event(find_by, abi, ele) do
    abi
    |> get_events()
    |> Enum.find(fn event ->
      handle_event_ele(find_by, event) == ele
    end)
  end

  def handle_event_ele(:sig, event) do
    Event.get_signature(event)
  end
  def handle_event_ele(:name, event) do
    event.name
  end

  def find_func(find_by, abi, ele) do
    abi
    |> get_funcs()
    |> Enum.find(fn func ->
      handle_func_ele(find_by, func) == ele
    end)
  end

  def handle_func_ele(:sig, func) do
    Event.get_signature(func)
  end
  def handle_func_ele(:name, func) do
    func.name
  end

  def gen_sig(name, inputs) do
    "#{name}(#{inputs |> Enum.map(&Argument.canonical_type_of(&1.type)) |> Enum.join(",")})"
  end
end
