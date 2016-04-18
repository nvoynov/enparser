# Enparser

Enparser is a simple Command Line Interface tool to segment by phrases and extract word lemmas from plain English text. It works only for English.

There is nothing new under the Sun and it was possible thanks to existence three great gems - [pragmatic_segmenter](https://github.com/diasks2/pragmatic_segmenter),  [lemmatizer](https://github.com/yohasebe/lemmatizer), and [thor](https://github.com/erikhuda/thor). Many thanks to their authors.

Enparser was born as result of my efforts during extract unknown English words from text sources - subtitle files and books. Something like 'new vocabulary first'.

## Installation

You must have installer Ruby. I'm using Ruby 2.2.4 under Win10 and can't guarantee correct work under other OS or Ruby installations. But I hope it will work, because it works on Windows :)

The simplest way is installation through gem manager:

    $ gem install enparser

Of course you can choose the other way through cloning repository and installing the gem by hands (you must also have [Bundler](http://bundler.io/) installed):

    $ git clone https://github.com/nvoynov/enparser.git
    $ cd enparser    
    $ bundle install
    $ bundle exec rake install


## Usage

Because this CLI based on Thor, you can always get help by:

    $ enparse help
    $ enparse help COMMAND

By default all commands write its results to SDOUT. And of course you can redirect output to file by adding redirect operator `... > output_file_name`

### Segment

Command `segment` scans input file and outputs segments (sentences) to STDOUT. Through option `--skip-patterns`, the command provides ability of skipping certain lines from output which match to set of regular expressions.

```
Usage:
  enparse segment FILE_NAME [SKIP_PATTERNS]
```

Let's suppose you have a subtitle file `subtitle.srt` and you want to get a more convenient for reading script file:
```
151
00:07:39,159 --> 00:07:40,190
There's a big country out there,

152
00:07:40,226 --> 00:07:41,822
we need to take it by the hand, tell

153
00:07:41,823 --> 00:07:44,563
it a story. We wait too
long, somebody else will,

154
00:07:44,564 --> 00:07:46,965
then we'll never get control of this thing.

155
00:07:46,966 --> 00:07:48,167
Sir?
```

At first, let's get out from timing information and create file `subtitle_timig.skip` with skip line patterns(TODO: comments in regexp files!).
```
^\n$
^(\d)+$
^\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}$
```

Then, execute command:

    $ enparse segment subtitle.srt subtitle_timing.skip

As a result of this command, you will see the next output:
```
There's a big country out there, we need to take it by the hand, tell it a story.
We wait too long, somebody else will, then we'll never get control of this thing.
Sir?
```

### Lemmatize

Command `lemmatize` scans input file; extracts words, lemmas, forms and frequency; and outputs words information to STDOUT.

```
Usage:
  enparse lemmatize FILE_NAME [SKIP_SOURCES]

Options:
  -s, [--separator=SEPARATOR]                        # Separator between lemma, count and forms
                                                     # Default:
  -d, [--load-default], [--no-load-default]          # Skip loading skip_default_set.
  -l, [--strict-by-lemmas], [--no-strict-by-lemmas]  # Output only lemmas.

Extract words, lemma, forms and frequency to STDOUT
```

Each `SKIP_SOURCE` file can contain string of words separated by spaces. You can see content of default words to skip bellow as an example. `SKIP_SOURCES` accepts file name, file patters, and all possible combinations. Each next skip part must be followed after `;`. For example `basic-set.txt;tvshow-learned*.txt;`

By default command `lemmatize` uses the next predefined pragmatic set of words to skip. This loading can be skipped by option `--no-load-default`:
```
I he she it you we they
my me him his her its us our their your yours them self
a an the this that these those all that's
here there
be do have will not want
can can't cannot could couldn't must mustn't should shouldn't may might mayn't mightn't won't would
I'm he's she's it's we're they're i've they've he'd she'd we've
isn't aren't don't doesn't didn't weren't wasn't haven't hadn't hasn't
who who's what what's where when whose which how why
if then else unless for from till until while begin end start finish though although because true false any
and also or yes no not for to at as of on by but about just in with so too up down left right bottom before after back out more less than
one two three four five six seven eight nine ten eleven twelf
first last second third
now day eve today tomorrow yesterday
month january february march april may june july august september october november december
season year winter spring summer autumn
week Monday Tuesday Wednesday Thursday Friday Saturday Sunday
mr. ms.
go try know let make take say find need see get tell think mean ask time move call buy talk thank use
every each very
ever never even
name thing anything nothing other another
gonna wanna
```

Just for example, there is a fragment of lemmatize 570 pages book result:
```
figure 388 (figuring)
owner 400 (owners)
new 414 (newer)
value 439 (valued,values)
business 448 (businesses)
iteration 456 (iterations)
estimate 460 (estimating,estimates,estimated)
chapter 460 (chapters)
software 466
work 491 (works,working,worked)
epic 496 (epics)
```

### New vocabulary note

Now I start using this cli to extract new words from texts (TV show subtitles and books). Usually I extract 40-80 new words from one TV show episode, and it is around 10% of total episode vocabulary. During first few session I recommend do next flow:
* extract all words and output only lemmas `enparse subtitle-file.srt --strict-by-lemmas > known-words.txt`;
* delete unknown words form `known-words.txt` by hands;
* and skip `known-words.txt` by second iteration `enparse subtitle-file.srt known-words.txt > unknown-words.txt`

### Phrasal verbs?

`WordNet` divide words by part of speech - noun, verb, adv, adj. It is possible extend by prepositions, and then try to analyze patterns
* verb + prep,
* verb + pronoun + prep,
* verb + noun + verb + prep.

Unfortunately, current implementation of `lemmalizer` don't allow to return part of speech for word. It'll require some modifications.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/enparser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
