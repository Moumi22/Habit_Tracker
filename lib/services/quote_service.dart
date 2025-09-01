import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote_model.dart';

class QuoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Free quotes API endpoints
  static const String _quotableApi = 'https://api.quotable.io/random';
  static const String _zenQuotesApi = 'https://zenquotes.io/api/random';

    // Fetch random quotes from external API
  Future<List<QuoteModel>> fetchRandomQuotes({int count = 5}) async {
    try {
      final List<QuoteModel> quotes = [];
      
      // Try Quotable API first
      try {
        for (int i = 0; i < count; i++) {
          final response = await http.get(Uri.parse(_quotableApi));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final quote = QuoteModel(
              id: _generateQuoteId(data['content']),
              text: data['content'],
              author: data['author'] ?? 'Unknown',
              category:
                  data['tags']?.isNotEmpty == true ? data['tags'][0] : null,
            );
            quotes.add(quote);
          }
        }
      } catch (e) {
        print('Quotable API failed: $e');
        // Fallback to ZenQuotes if Quotable fails
        try {
          for (int i = 0; i < count; i++) {
            final response = await http.get(Uri.parse(_zenQuotesApi));
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data.isNotEmpty) {
                final quote = QuoteModel(
                  id: _generateQuoteId(data[0]['q']),
                  text: data[0]['q'],
                  author: data[0]['a'] ?? 'Unknown',
                );
                quotes.add(quote);
              }
            }
          }
        } catch (e2) {
          print('ZenQuotes API also failed: $e2');
          // Return offline quotes if both APIs fail
          return _getOfflineQuotes(count);
        }
      }
      
      // If we got some quotes but not enough, fill with offline quotes
      if (quotes.length < count) {
        final offlineQuotes = _getOfflineQuotes(count - quotes.length);
        quotes.addAll(offlineQuotes);
      }
      
      return quotes;
    } catch (e) {
      print('All quote fetching failed: $e');
      // Return offline quotes as final fallback
      return _getOfflineQuotes(count);
    }
  }

  // Generate a unique ID for quotes
  String _generateQuoteId(String text) {
    return text.hashCode.toString();
  }

  // Get offline quotes when APIs fail
  List<QuoteModel> _getOfflineQuotes(int count) {
    final offlineQuotes = [
      QuoteModel(
        id: 'offline_1',
        text: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
        category: 'Motivation',
      ),
      QuoteModel(
        id: 'offline_2',
        text: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        author: 'Winston Churchill',
        category: 'Success',
      ),
      QuoteModel(
        id: 'offline_3',
        text: 'The future belongs to those who believe in the beauty of their dreams.',
        author: 'Eleanor Roosevelt',
        category: 'Dreams',
      ),
      QuoteModel(
        id: 'offline_4',
        text: 'Don\'t watch the clock; do what it does. Keep going.',
        author: 'Sam Levenson',
        category: 'Persistence',
      ),
      QuoteModel(
        id: 'offline_5',
        text: 'The only limit to our realization of tomorrow will be our doubts of today.',
        author: 'Franklin D. Roosevelt',
        category: 'Belief',
      ),
      QuoteModel(
        id: 'offline_6',
        text: 'Life is what happens to you while you\'re busy making other plans.',
        author: 'John Lennon',
        category: 'Life',
      ),
      QuoteModel(
        id: 'offline_7',
        text: 'The way to get started is to quit talking and begin doing.',
        author: 'Walt Disney',
        category: 'Action',
      ),
      QuoteModel(
        id: 'offline_8',
        text: 'Your time is limited, don\'t waste it living someone else\'s life.',
        author: 'Steve Jobs',
        category: 'Life',
      ),
      QuoteModel(
        id: 'offline_9',
        text: 'If life were predictable it would cease to be life, and be without flavor.',
        author: 'Eleanor Roosevelt',
        category: 'Life',
      ),
      QuoteModel(
        id: 'offline_10',
        text: 'Life is a succession of lessons which must be lived to be understood.',
        author: 'Ralph Waldo Emerson',
        category: 'Wisdom',
      ),
    ];
    
    // Shuffle and return requested count
    offlineQuotes.shuffle();
    return offlineQuotes.take(count).toList();
  }

  // Get user's favorite quotes
  Stream<List<QuoteModel>> getUserFavoriteQuotes(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .orderBy('addedToFavorites', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => QuoteModel.fromMap(doc.data(), doc.id))
                    .toList(),
          )
          .handleError((error) {
            print('Error loading favorite quotes: $error');
            return <QuoteModel>[];
          });
    } catch (e) {
      print('Error accessing Firestore for favorites: $e');
      return Stream.value(<QuoteModel>[]);
    }
  }

  // Add quote to favorites
  Future<void> addQuoteToFavorites(String userId, QuoteModel quote) async {
    try {
      final favoriteQuote = quote.copyWith(
        isFavorite: true,
        addedToFavorites: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .doc(quote.id)
          .set(favoriteQuote.toMap());
    } catch (e) {
      print('Error adding quote to favorites: $e');
      // Don't throw error, just log it - app should work without favorites
      throw Exception('Failed to add quote to favorites: $e');
    }
  }

  // Remove quote from favorites
  Future<void> removeQuoteFromFavorites(String userId, String quoteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .doc(quoteId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove quote from favorites: $e');
    }
  }

  // Check if a quote is in user's favorites
  Future<bool> isQuoteInFavorites(String userId, String quoteId) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .doc('quotes')
              .collection('quotes')
              .doc(quoteId)
              .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Toggle quote favorite status
  Future<void> toggleQuoteFavorite(String userId, QuoteModel quote) async {
    try {
      if (quote.isFavorite) {
        await removeQuoteFromFavorites(userId, quote.id);
      } else {
        await addQuoteToFavorites(userId, quote);
      }
    } catch (e) {
      throw Exception('Failed to toggle quote favorite: $e');
    }
  }

  // Get inspirational quotes by category
  Future<List<QuoteModel>> getQuotesByCategory(
    String category, {
    int count = 3,
  }) async {
    try {
      final List<QuoteModel> quotes = [];

      // Try to get category-specific quotes from Quotable API
      try {
        final response = await http.get(
          Uri.parse(
            'https://api.quotable.io/quotes?tags=$category&limit=$count',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          for (final quoteData in data['results']) {
            final quote = QuoteModel(
              id: _generateQuoteId(quoteData['content']),
              text: quoteData['content'],
              author: quoteData['author'] ?? 'Unknown',
              category: category,
            );
            quotes.add(quote);
          }
        }
      } catch (e) {
        // Fallback to random quotes if category-specific fails
        return await fetchRandomQuotes(count: count);
      }

      return quotes;
    } catch (e) {
      throw Exception('Failed to fetch category quotes: $e');
    }
  }

  // Get daily quote (cached for the day)
  Future<QuoteModel?> getDailyQuote(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('daily_quotes')
              .doc(today.toIso8601String().split('T')[0])
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        return QuoteModel.fromMap(data, doc.id);
      }

      // If no daily quote exists, fetch a new one
      final quotes = await fetchRandomQuotes(count: 1);
      if (quotes.isNotEmpty) {
        final dailyQuote = quotes.first;

        // Save as daily quote
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('daily_quotes')
            .doc(today.toIso8601String().split('T')[0])
            .set(dailyQuote.toMap());

        return dailyQuote;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get daily quote: $e');
    }
  }
}
