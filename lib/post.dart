class Post {
  final String dados; // Descrição do problema do socorrista
  final String nome; // Nome do socorrista
  final String telefone; // Telefone do socorrista
  final String postID; // UID do socorrista
  final DateTime dataPublicada; // Data de publicação da emergência
  final bool status; // Status da emergência
  final String postURL; // URL da foto do socorrista
  final String token; // Token do socorrista

  const Post({
    required this.dados,
    required this.nome,
    required this.telefone,
    required this.postID,
    required this.dataPublicada,
    required this.status,
    required this.postURL,
    required this.token,
  });

  // Converte o objeto Post para um mapa (JSON)
  Map<String, dynamic> toJson() => {
    "dados": dados,
    "nome": nome,
    "telefone": telefone,
    "postID": postID,
    "dataPublicada": dataPublicada,
    "status": status,
    "postURL": postURL,
    "token": token,
  };
}
