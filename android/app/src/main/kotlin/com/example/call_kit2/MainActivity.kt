package com.example.call_kit2

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inicialize o MethodChannel para comunicação com o Flutter
        channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, "flutter_callkit_channel")

        // Verifica se o aplicativo foi aberto pelo Flutter CallKit
        val appOpenedIntent = intent
        if (appOpenedIntent != null && appOpenedIntent.action == "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT") {
            val extras = appOpenedIntent.extras
            if (extras != null) {
                // Captura os dados da chamada
                val callData = fromBundle(extras)
                Log.d("FlutterCallKit", "App inicializado pelo Flutter CallKit com dados: $callData")

                // Envia os dados da chamada para o Flutter
                channel.invokeMethod("onCallAccepted", callData)
            }
        }
    }

    private fun fromBundle(bundle: Bundle): Map<String, Any?> {
    val data: HashMap<String, Any?> = HashMap()
    val extraCallkitData = bundle.getBundle("EXTRA_CALLKIT_CALL_DATA")
    
    if (extraCallkitData != null) {
        // Inspeciona e extrai os dados do extraCallkitData
        for (key in extraCallkitData.keySet()) {
            val value = extraCallkitData.get(key)
            
            // Verifique se o valor é do tipo esperado, aqui como exemplo tratamos algumas possibilidades
            when (value) {
                is String -> data[key] = value
                is Int -> data[key] = value
                is Boolean -> data[key] = value
                //is Serializable -> data[key] = value // Isso vai pegar qualquer tipo Serializable
                else -> Log.w("FlutterCallKit", "Tipo desconhecido para chave: $key")
            }
            
            Log.d("FlutterCallKit", "Key: $key, Value: $value")
        }
    } else {
        Log.d("FlutterCallKit", "EXTRA_CALLKIT_CALL_DATA está vazio ou nulo")
    }
    
    return data
}

    
}
