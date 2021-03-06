import 'package:batch/batch.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

void main(List<String> args) => BatchApplication(
      jobs: [AutoRetweetJob()],
    )..run();

class AutoRetweetJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'name',
        schedule: CronParser('* */1 * * *'), // Will be executed hourly
        steps: [
          Step(
            name: 'Auto Retweet Step',
            task: AutoRetweetTask(),
          ),
        ],
      );
}

class AutoRetweetTask extends Task<AutoRetweetTask> {
  @override
  Future<void> execute(ExecutionContext context) async {
    // You need to get your own tokens from https://apps.twitter.com/
    final twitter = TwitterApi(
      bearerToken: 'YOUR_BEARER_TOKEN_HERE',

      // Or you can use OAuth 1.0a tokens.
      oauthTokens: OAuthTokens(
        consumerKey: 'YOUR_API_KEY_HERE',
        consumerSecret: 'YOUR_API_SECRET_HERE',
        accessToken: 'YOUR_ACCESS_TOKEN_HERE',
        accessTokenSecret: 'YOUR_ACCESS_TOKEN_SECRET_HERE',
      ),
    );

    try {
      // You need your user id to create retweet.
      final me = await twitter.usersService.lookupMe();
      // Search for tweets
      final tweets = await twitter.tweetsService.searchRecent(query: '#coding');

      int count = 0;
      for (final tweet in tweets.data) {
        if (count >= 10) {
          // Stop after 10 auto-retweets
          return;
        }

        // Auto retweet
        await twitter.tweetsService.createRetweet(
          userId: me.data.id,
          tweetId: tweet.id,
        );

        count++;
      }
    } catch (e, s) {
      log.error('Failed to retweet', e, s);
    }
  }
}
