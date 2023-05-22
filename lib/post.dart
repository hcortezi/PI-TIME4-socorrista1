class Post {
  final String dados;
  final String postID;
  final dataPublicada;
  final String postURL;

  const Post({
    required this.dados,
    required this.postID,
    required this.dataPublicada,
    required this.postURL,
  });

  Map<String, dynamic> toJson() => {
    "dados": dados,
    "postID": postID,
    "dataPublicada": dataPublicada,
    "postURL": postURL,
  };
}