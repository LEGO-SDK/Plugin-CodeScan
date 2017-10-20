package com.opensource.legosdk.plugin.codescan

import com.opensource.legosdk.core.LGORequestable
import com.opensource.legosdk.core.LGOResponse

/**
 * Created by cuiminghui on 2017/10/17.
 */
class LGOCodeScanOperation(val request: LGOCodeScanRequest): LGORequestable() {

    override fun requestSynchronize(): LGOResponse {
        return LGOCodeScanResponse().accept(null)
    }

    override fun requestAsynchronize(callbackBlock: (LGOResponse) -> Unit) {
        callbackBlock.invoke(requestSynchronize())
    }

}