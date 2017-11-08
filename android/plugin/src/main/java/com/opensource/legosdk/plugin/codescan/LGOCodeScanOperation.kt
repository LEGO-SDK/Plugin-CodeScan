package com.opensource.legosdk.plugin.codescan

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import com.opensource.legosdk.core.LGORequestable
import com.opensource.legosdk.core.LGOResponse
import android.provider.MediaStore
import com.google.zxing.*
import com.google.zxing.qrcode.QRCodeReader
import com.google.zxing.common.HybridBinarizer
import java.util.*


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
                LGOCodeScanOperation.callbackBlock = callbackBlock
                if (request.opt.equals("Scan")) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            if (ContextCompat.checkSelfPermission(requestActivity, android.Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                                ActivityCompat.requestPermissions(requestActivity, arrayOf(android.Manifest.permission.CAMERA), 1)
                                return@runOnUiThread
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                            LGOCodeScanOperation.callbackBlock?.invoke(LGOCodeScanResponse().reject("Plugin.CodeScan", -4, e.localizedMessage))
                        }
                    }
                    val intent = Intent(requestActivity, CodeScanActivity::class.java)
                    request.closeAfter?.let {
                        intent.putExtra("closeAfter",it)
                    }
                    requestActivity.startActivity(intent)
                } else if (request.opt.equals("Recognition")) {
                    requestActivity.startActivity(Intent(requestActivity, ImagePickerHandleActivity::class.java))
                }

            }
        }

    }

    class ImagePickerHandleActivity: Activity() {

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            val albumIntent = Intent(Intent.ACTION_PICK, null)
            albumIntent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
            startActivityForResult(albumIntent, 9527)
        }

        override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
            super.onActivityResult(requestCode, resultCode, data)
            when (requestCode) {
                9527 -> {
                    try {
                        data?.let { intentData ->
                            val inputStream = contentResolver.openInputStream(intentData.data)
                            val pickedImage = BitmapFactory.decodeStream(inputStream)
                            pickedImage?.let {
                                val result = scanningImage(it)
                                val response = LGOCodeScanResponse()
                                response.result = result
                                LGOCodeScanOperation.callbackBlock?.invoke(response.accept(null))
                            }

                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        LGOCodeScanOperation.callbackBlock?.invoke(LGOCodeScanResponse().reject("Plugin.CodeScan", -1, e.localizedMessage))
                    }
                }
            }
            finish()

        }

        fun scanningImage(parameBitMap: Bitmap): String {

            val hints = Hashtable<DecodeHintType, String>()
            hints.put(DecodeHintType.CHARACTER_SET, "utf-8")
            val pixelArray = IntArray(parameBitMap.width * parameBitMap.height)
            parameBitMap.getPixels(pixelArray, 0, parameBitMap.width, 0, 0, parameBitMap.width, parameBitMap.height)
            val source = RGBLuminanceSource(parameBitMap.width, parameBitMap.height, pixelArray)
            val tempBitmap = BinaryBitmap(HybridBinarizer(source))

            val reader = QRCodeReader()
            try {
                val result: Result = reader.decode(tempBitmap, hints)
                return result.text
            } catch (e: Exception) {
                e.printStackTrace()
                if (e !is NotFoundException) {
                    LGOCodeScanOperation.callbackBlock?.invoke(LGOCodeScanResponse().reject("Plugin.CodeScan", -2, e.localizedMessage))
                }
            }
            return ""
        }
    }
}

