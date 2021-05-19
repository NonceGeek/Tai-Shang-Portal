
# WeLight-Portal

APIs about WeLight Portal.

## Indices

* [contract_interactor](#contract_interactor)

  * [get_contracts](#1-get_contracts)
  * [interact_with_contract](#2-interact_with_contract)

* [weidentity_interactor](#weidentity_interactor)

  * [create_weid](#1-create_weid)


--------


## contract_interactor

### 1. get_contracts



***Endpoint:***

```bash
Method: GET
Type: 
URL: {{host}}:{{http_port}}/welight/api/v1/contracts
```



***Query params:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



***More example Requests/Responses:***


##### I. Example Request: get_contracts



***Query:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



##### I. Example Response: get_contracts
```js
[
    {
        "description": "柏链存证合约",
        "events": [
            {
                "args": [
                    {
                        "indexed": false,
                        "name": "evi",
                        "type": "string"
                    }
                ],
                "name": "addSignaturesEvent"
            }
            // …………
        ],
        "id": 1,
        "init_params": {
            "evidenceSigners": [
                "0x085154d302b49577252c17c9fd7fad354347b596"
            ]
        },
        "type": "Evidence"
    }
]
```


***Status Code:*** 200

<br>



### 2. interact_with_contract



***Endpoint:***

```bash
Method: POST
Type: RAW
URL: {{host}}:{{httpport}}/welight/api/v1/contract/func
```



***Query params:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



***Body:***

```js        
{
    "contract_id": 1,
    "func": "newEvidence",
    "params": {
        "signer": "0xbf1731dc34c4c6f9cb034b9386931318f365bda3",
        "evidence": "{'resource':'642e92efb79421734881b53e1e1b18b6','app_id':'1','operator':'did:weid:1:0xc67cfde9ea960c4eb449f84b3127770034174c8c','action':'behavior.study.plan.task'}"
    }
}
```



***More example Requests/Responses:***


##### I. Example Request: interact_with_contract



***Query:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



***Body:***

```js        
{
    "contract_id": 1,
    "func": "newEvidence",
    "params": {
        "signer": "0x085154d302b49577252c17c9fd7fad354347b596",
        "evidence": "{'resource':'642e92efb79421734881b53e1e1b18b6','app_id':'1','operator':'did:weid:1:0xc67cfde9ea960c4eb449f84b3127770034174c8c','action':'behavior.study.plan.task'}"
    }
}
```



##### I. Example Response: interact_with_contract
```js
{
    "result": {
        "contract_id": 1,
        "description": null,
        "id": 10,
        "inserted_at": "2021-02-27T02:09:04",
        "key": "0x65f702f98b05b96a47d40e7582a618fa15cc5dbd",
        "owners": [
            "0x085154d302b49577252c17c9fd7fad354347b596"
        ],
        "signers": [
            "0x085154d302b49577252c17c9fd7fad354347b596"
        ],
        "tx_id": "0x855f072a0eae73e89352d91db62c4d1eed16dc57361c3b28a8b1c807faae0951",
        "updated_at": "2021-02-27T02:09:04",
        "value": "{}"
    },
    "error_code": 0,
    "error_msg": "success"
}
```


***Status Code:*** 200

<br>



## weidentity_interactor



### 1. create_weid



***Endpoint:***

```bash
Method: POST
Type: RAW
URL: {{host}}:{{httpport}}/welight/api/v1/weid/create
```



***Query params:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



***Body:***

```js        
{"chain_id": 1}
```



***More example Requests/Responses:***


##### I. Example Request: create_weid



***Query:***

| Key | Value | Description |
| --- | ------|-------------|
| app_id | 1 |  |
| secret_key | {{secret_key}} |  |



***Body:***

```js        
{"chain_id": 1}
```



##### I. Example Response: create_weid
```js
{
    "error_code": 0,
    "error_msg": "success",
    "result": "did:weid:1:0x5e84ce01a3ecfb012e06b93d732eb4e1df047754"
}
```


***Status Code:*** 200

<br>



---
[Back to top](#welight-portal)
> Made with &#9829; by [thedevsaddam](https://github.com/thedevsaddam) | Generated at: 2021-05-19 14:55:42 by [docgen](https://github.com/thedevsaddam/docgen)