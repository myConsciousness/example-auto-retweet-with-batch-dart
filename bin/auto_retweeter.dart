import 'package:batch/batch.dart';
import 'package:dart_twitter_api/twitter_api.dart';

void main(List<String> args) => BatchApplication()
  ..addJob(Job(
    name: 'Auto Retweet Job',
    schedule: CronParser(value: '0 */1 * * *'), // Will be executed hourly
  )..nextStep(
      Step(name: 'Auto Like Tweet Step')..registerTask(AutoRetweetTask()),
    ))
  ..run();

class AutoRetweetTask extends Task<AutoRetweetTask> {
  @override
  Future<void> execute(ExecutionContext context) async {
    // You need to get your own API keys from https://apps.twitter.com/
    final twitter = TwitterApi(
      client: TwitterClient(
        consumerKey: 'Your consumer key',
        consumerSecret: 'Your consumer secret',
        token: 'Your token',
        secret: 'Your secret',
      ),
    );

    try {
      // Search for tweets
      final tweets =
          await twitter.tweetSearchService.searchTweets(q: '#coding');

      int count = 0;
      for (final status in tweets.statuses!) {
        if (count >= 10) {
          // Stop after 10 auto-retweets
          return;
        }

        // Auto retweet
        await twitter.tweetService.retweet(id: status.idStr!);
        count++;
      }
    } catch (e, s) {
      log.error('Failed to retweet', e, s);
    }
  }
}
