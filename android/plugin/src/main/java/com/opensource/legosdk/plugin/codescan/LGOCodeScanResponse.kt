package com.opensource.legosdk.plugin.codescan

import com.opensource.legosdk.core.LGOResponse

class LGOCodeScanResponse: LGOResponse() {

    var result: String? = null

    override fun resData(): HashMap<String, Any> {
        return hashMapOf(
            Pair("result", this.result ?: "")
        )
    }

}