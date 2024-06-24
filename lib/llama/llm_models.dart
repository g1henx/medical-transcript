import 'package:fllama/model/model_override.dart';

class LlmModel {
  final String name;
  final String path;
  final double size; //In GB
  final ModelOverride template;
  final int maxContext;
  LlmModel({required this.name, required this.path , required this.size, required this.maxContext , required this.template});
}
///LLama
LlmModel llamaSmall = LlmModel(name: 'Llama Small', path: 'https://huggingface.co/openbmb/MiniCPM-Llama3-V-2_5-gguf/resolve/main/ggml-model-Q3_K_S.gguf', maxContext: 8000, size: 3.67, template: Llama3ChatTemplate());
LlmModel llamaMedium = LlmModel(name: 'Llama Medium', path: 'https://huggingface.co/openbmb/MiniCPM-Llama3-V-2_5-gguf/resolve/main/ggml-model-Q4_0.gguf', maxContext: 8000, size: 4.66, template: Llama3ChatTemplate());
LlmModel llamaBig = LlmModel(name: 'Llama Big', path: 'https://huggingface.co/openbmb/MiniCPM-Llama3-V-2_5-gguf/resolve/main/ggml-model-Q5_0.gguf', maxContext: 8000, size: 5.6, template: Llama3ChatTemplate());
///Qwen2-0.5
LlmModel qwen205Small = LlmModel(name: 'Qwen2-0.5 Small', path: 'https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-q4_0.gguf',maxContext:  130000 , size: 0.4, template: QwenChatTemplate());
LlmModel qwen205Medium = LlmModel(name: 'Qwen2-0.5 Medium', path: 'https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-q8_0.gguf' ,maxContext:  130000, size: 0.6, template: QwenChatTemplate());
LlmModel qwen205Big = LlmModel(name: 'Qwen2-0.5 Big', path: 'https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-fp16.gguf',maxContext:  130000 , size: 1.27, template: QwenChatTemplate() );
///Qwen2-1.5
LlmModel qwen215Small = LlmModel(name: 'Qwen2-1.5 Small', path: 'https://huggingface.co/MaziyarPanahi/Qwen2-1.5B-Instruct-GGUF/resolve/main/Qwen2-1.5B-Instruct.IQ1_M.gguf',maxContext:  130000, size: 0.46, template: QwenChatTemplate());
LlmModel qwen215Medium = LlmModel(name: 'Qwen2-1.5 Medium', path: 'https://huggingface.co/MaziyarPanahi/Qwen2-1.5B-Instruct-GGUF/resolve/main/Qwen2-1.5B-Instruct.IQ4_XS.gguf',maxContext:  130000, size: 0.9, template: QwenChatTemplate());
LlmModel qwen215Big = LlmModel(name: 'Qwen2-1.5 Big', path: 'https://huggingface.co/MaziyarPanahi/Qwen2-1.5B-Instruct-GGUF/resolve/main/Qwen2-1.5B-Instruct.fp16.gguf',maxContext:  130000, size: 3.96, template: QwenChatTemplate());
///Qwen2-7
LlmModel qwen27Small = LlmModel(name: 'Qwen2-7 Small', path: 'https://huggingface.co/Qwen/Qwen2-7B-Instruct-GGUF/resolve/main/qwen2-7b-instruct-q5_0.gguf',maxContext:  130000, size: 5.1, template: QwenChatTemplate());
LlmModel qwen27Medium = LlmModel(name: 'Qwen2-7 Medium', path: 'https://huggingface.co/Qwen/Qwen2-7B-Instruct-GGUF/resolve/main/qwen2-7b-instruct-q6_k.gguf',maxContext:  130000, size: 6.2, template: QwenChatTemplate());
LlmModel qwen27Big = LlmModel(name: 'Qwen2-7 Big', path: 'https://huggingface.co/Qwen/Qwen2-7B-Instruct-GGUF/resolve/main/qwen2-7b-instruct-q8_0.gguf',maxContext:  130000, size: 8.1, template: QwenChatTemplate());
///Phi3
//LlmModel phi3Small = LlmModel(name: 'Phi3 Small', path: 'https://huggingface.co/openbmb/MiniCPM-Phi3-V-2_5-gguf/resolve/main/ggml-model-Q3_K_S.gguf');
LlmModel phi3Medium = LlmModel(name: 'Phi3', path: 'https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf' ,maxContext: 4000, size: 2.36, template: Phi3ChatTemplate());
LlmModel phi3Big = LlmModel(name: 'Phi3 Big', path: 'https://huggingface.co/bartowski/Phi-3-medium-128k-instruct-GGUF/resolve/main/Phi-3-medium-128k-instruct-Q4_K_S.gguf',maxContext: 128000, size: 8, template: Phi3ChatTemplate());
///Mistral
LlmModel mistralSmall = LlmModel(name: 'Mistral Small', path: 'https://huggingface.co/MaziyarPanahi/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3.IQ1_M.gguf', maxContext: 8192, size: 1.76, template: Phi3ChatTemplate());
LlmModel mistralMedium = LlmModel(name: 'Mistral Medium', path: 'https://huggingface.co/MaziyarPanahi/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3.IQ3_XS.gguf', maxContext: 8192, size: 3.02, template: Phi3ChatTemplate());
LlmModel mistralBig = LlmModel(name: 'Mistral Big', path: 'https://huggingface.co/MaziyarPanahi/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3.Q8_0.gguf', maxContext: 8192, size: 7.7, template: Phi3ChatTemplate());

///GEmma
LlmModel gemma = LlmModel(name: 'Gemma', path: 'https://huggingface.co/NikolayKozloff/SauerkrautLM-Gemma-2b-Q8_0-GGUF/resolve/main/sauerkrautlm-gemma-2b-q8_0.gguf', maxContext: 2048, size: 4, template: GemmaChatTemplate());
