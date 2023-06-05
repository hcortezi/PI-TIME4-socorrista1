class Post {
  final String dados;
  final String nome;
  final String telefone;
  final String postID;
  final dataPublicada;
  final status;
  final String postURL;

  const Post({
    required this.dados,
    required this.nome,
    required this.telefone,
    required this.postID,
    required this.dataPublicada,
    required this.status,
    required this.postURL,
  });

  Map<String, dynamic> toJson() => {
    "dados": dados,
    "nome": nome,
    "telefone": telefone,
    "postID": postID,
    "dataPublicada": dataPublicada,
    "status": status,
    "postURL": postURL,
  };
}