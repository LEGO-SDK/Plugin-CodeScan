package com.opensource.legosdk.plugin.codescan

import com.opensource.legosdk.core.*
import org.json.JSONObject

class LGOCodeScan: LGOModule() {

    override fun buildWithJSONObject(obj: JSONObject, context: LGORequestContext): LGORequestable? {
        val request = LGOCodeScanRequest(context)
        request.opt = obj.optString("opt")
        return LGOCodeScanOperation(request)
    }

}