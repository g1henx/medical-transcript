class EmbeddingsModel{
  final String name;
  final String path;
  EmbeddingsModel({required this.name, required this.path});
}

EmbeddingsModel nomic = EmbeddingsModel(name: 'Embeddings', path: 'https://huggingface.co/nomic-ai/nomic-embed-text-v1.5/resolve/main/onnx/model.onnx');
EmbeddingsModel nomicGGUF = EmbeddingsModel(name: 'Embeddings GGUF', path: 'https://huggingface.co/mixedbread-ai/mxbai-embed-large-v1/resolve/main/onnx/model_fp16.onnx');
EmbeddingsModel nomicQ = EmbeddingsModel(name: 'Embeddings Small', path: 'https://huggingface.co/nomic-ai/nomic-embed-text-v1.5/resolve/main/onnx/model_quantized.onnx');
EmbeddingsModel allMiniLLm6 = EmbeddingsModel(name: 'Embeddings XSmall', path: 'https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main/onnx/model.onnx');