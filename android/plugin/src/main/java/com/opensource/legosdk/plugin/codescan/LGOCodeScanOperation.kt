package com.opensource.legosdk.plugin.codescan

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import com.opensource.legosdk.core.LGORequestable
import com.opensource.legosdk.core.LGOResponse

/**
 * Created by cuiminghui on 2017/10/17.
 */
class LGOCodeScanOperation(val request: LGOCodeScanRequest): LGORequestable() {

    companion object {
        var callbackBlock: ((LGOResponse) -> Unit)? = null
    }

    override fun requestAsynchronize(callbackBlock: (LGOResponse) -> Unit) {
        request.context?.requestActivity()?.let { requestActivity ->
            requestActivity.runOnUiThread {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    try {
                        if (ContextCompat.checkSelfPermission(requestActivity, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(requestActivity, arrayOf(android.Manifest.permission.CAMERA), 1)
                            return@runOnUiThread
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
                LGOCodeScanOperation.callbackBlock = callbackBlock
                val intent = Intent(requestActivity, CodeScanActivity::class.java)
                request.closeAfter?.let {
                    intent.putExtra("closeAfter",it)
                }
                requestActivity.startActivity(intent)
            }
        }

    }

}