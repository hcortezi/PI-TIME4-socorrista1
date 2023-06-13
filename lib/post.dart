class Post {
  final String dados;
  final String nome;
  final String telefone;
  final String postID;
  final dataPublicada;
  final status;
  final String postURL;
  final String token;


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