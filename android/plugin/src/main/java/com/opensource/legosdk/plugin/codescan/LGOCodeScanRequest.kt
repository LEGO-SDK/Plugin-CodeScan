package com.opensource.legosdk.plugin.codescan

import com.opensource.legosdk.core.LGORequest
import com.opensource.legosdk.core.LGORequestContext

/**
 * Created by cuiminghui on 2017/10/17.
 */

class LGOCodeScanRequest(context: LGORequestContext?) : LGORequest(context) {

    var opt: String? = null
    var closeAfter: Boolean = true

}