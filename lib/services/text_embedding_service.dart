import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

/// The type of embeddings being produced
/// If the texts are passages (i.e. documents) then use .passage 
/// If the texts represent search query(s) then use .query
enum EmbeddingPassageType {passage,query}

/// API Docs: https://deepinfra.com/intfloat/multilingual-e5-large/api
class TextEmbeddingService {
  static const baseURL = 'https://api.deepinfra.com/v1/inference/intfloat/multilingual-e5-large';

  Future<EmbeddingResponse?> getEmbeddings(List<String> texts, EmbeddingPassageType passageType) async {

    // e5 class models expect a prefix based on whether we are looking at a passage or a query
    // this is one of the features that is supposed to aid information retrieval
    late final String prefix;
    switch (passageType){
      case EmbeddingPassageType.passage: prefix = "Passage";
      case EmbeddingPassageType.query: prefix = "Query";
    }
    texts = texts.map((text) => "$prefix: $text").toList();

    Map<String, String> headers = <String, String>{
      "Authorization": "bearer 1ZRoR5bOMvXBW0vpPO28vqHs4CBZLrNc" // TODO: This is a security flaw, Must fix before launch
    };

    Map<String, dynamic> body = <String, dynamic>{
      "inputs": texts,
      "normalize": "true"
    };

    Response res = await post(
      Uri.parse(baseURL), 
      headers: headers,
      body: jsonEncode(body)
    );
    debugPrint("${res.statusCode}");
    switch (res.statusCode){
      case 200: 
        Map<String, dynamic> body = jsonDecode(res.body);
        EmbeddingResponse embedding = EmbeddingResponse.fromJson(body);
        return embedding;
      case 429:
        debugPrint("Servers busy, you will need to retry later"); // don't want an exception here
        // TODO: modify this function so that it can call itself for retries up to x number of times
      case 400: throw "400 Bad Request: Malformed request Request:\n $body";
      case 403: throw "403 Forbidden: Unauthorized access to text Embeddings service @ $baseURL";
      case 404: throw "404 not found: unable to reach host @ $baseURL";
      default: 
        debugPrint(res.body);

    }
    return null;
  }

}

class EmbeddingResponse {
  final List<List<double>> embeddings;
  final int inputTokens;

  EmbeddingResponse({
    required this.embeddings,
    required this.inputTokens
  });

  factory EmbeddingResponse.fromJson(Map<String, dynamic> json) {
    try {
      List<List<double>> embeddings = List<List<double>>.from(json["embeddings"].map((e) => List<double>.from(e)));
      return EmbeddingResponse(embeddings: embeddings, inputTokens: json["input_tokens"]);
    } catch (e) {
      debugPrint("Issue deserialising Text Embedding Json: \n$e");
      rethrow;
    }
  }

}
