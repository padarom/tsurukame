// Copyright 2018 David Sansome
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "Wanikani+Convenience.h"

#import <UIKit/UIKit.h>

NSString *WKSRSLevelName(int srsLevel) {
  switch (srsLevel) {
    case 1:
      return @"Novice";
    case 2:
    case 3:
    case 4:
      return @"Apprentice";
    case 5:
    case 6:
      return @"Guru";
    case 7:
      return @"Master";
    case 8:
      return @"Enlightened";
    case 9:
      return @"Burned";
  }
  return nil;
}

@implementation WKSubject (Convenience)

- (NSAttributedString *)japaneseText {
  return [self japaneseTextWithImageSize:0];
}

- (NSAttributedString *)japaneseTextWithImageSize:(CGFloat)imageSize {
  if (!self.hasRadical || !self.radical.hasCharacterImageFile) {
    return [[NSAttributedString alloc] initWithString:self.japanese];
  }
  
  NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
  imageAttachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"radical-%d", self.id_p]];
  if (imageSize == 0) {
    imageSize = imageAttachment.image.size.width;
  }
  imageAttachment.bounds = CGRectMake(0, 0, imageSize, imageSize);
  return [NSAttributedString attributedStringWithAttachment:imageAttachment];
}

- (NSString *)subjectType {
  if (self.hasRadical) {
    return @"radical";
  }
  if (self.hasKanji) {
    return @"kanji";
  }
  if (self.hasVocabulary) {
    return @"vocabulary";
  }
  return nil;
}

- (NSString *)primaryMeaning {
  for (WKMeaning *meaning in self.meaningsArray) {
    if (meaning.isPrimary) {
      return meaning.meaning;
    }
  }
  return nil;
}

- (NSArray<WKReading *> *)primaryReadings {
  return [self readingsFilteredByPrimary:YES];
}

- (NSArray<WKReading *> *)alternateReadings {
  return [self readingsFilteredByPrimary:NO];
}

- (NSArray<WKReading *> *)readingsFilteredByPrimary:(BOOL)primary {
  NSMutableArray<WKReading *> *ret = [NSMutableArray array];
  for (WKReading *reading in self.readingsArray) {
    if (reading.isPrimary == primary) {
      [ret addObject:reading];
    }
  }
  return ret;
}

- (NSString *)commaSeparatedMeanings {
  NSMutableArray<NSString *>* strings = [NSMutableArray array];
  for (WKMeaning *meaning in self.meaningsArray) {
    [strings addObject:meaning.meaning];
  }
  return [strings componentsJoinedByString:@", "];
}

- (NSString *)commaSeparatedReadings {
  NSMutableArray<NSString *>* strings = [NSMutableArray array];
  for (WKReading *reading in self.readingsArray) {
    [strings addObject:reading.reading];
  }
  return [strings componentsJoinedByString:@", "];
}

- (NSString *)commaSeparatedPrimaryReadings {
  NSMutableArray<NSString *>* strings = [NSMutableArray array];
  for (WKReading *reading in self.primaryReadings) {
    [strings addObject:reading.reading];
  }
  return [strings componentsJoinedByString:@", "];
}

@end

@implementation WKVocabulary (Convenience)

- (NSString *)commaSeparatedPartsOfSpeech {
  NSMutableArray<NSString *> *parts = [NSMutableArray array];
  [self.partsOfSpeechArray enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL * _Nonnull stop) {
    NSString *str;
    switch ((WKVocabulary_PartOfSpeech)value) {
      case WKVocabulary_PartOfSpeech_Noun:             str = @"Noun";              break;
      case WKVocabulary_PartOfSpeech_Numeral:          str = @"Numeral";           break;
      case WKVocabulary_PartOfSpeech_IntransitiveVerb: str = @"Intransitive Verb"; break;
      case WKVocabulary_PartOfSpeech_IchidanVerb:      str = @"Ichidan Verb";      break;
      case WKVocabulary_PartOfSpeech_TransitiveVerb:   str = @"Transitive Verb";   break;
      case WKVocabulary_PartOfSpeech_NoAdjective:      str = @"No Adjective";      break;
      case WKVocabulary_PartOfSpeech_GodanVerb:        str = @"Godan Verb";        break;
      case WKVocabulary_PartOfSpeech_NaAdjective:      str = @"Na Adjective";      break;
      case WKVocabulary_PartOfSpeech_IAdjective:       str = @"I Adjective";       break;
      case WKVocabulary_PartOfSpeech_Suffix:           str = @"Suffix";            break;
      case WKVocabulary_PartOfSpeech_Adverb:           str = @"Adverb";            break;
      case WKVocabulary_PartOfSpeech_SuruVerb:         str = @"Suru Verb";         break;
      case WKVocabulary_PartOfSpeech_Prefix:           str = @"Prefix";            break;
      case WKVocabulary_PartOfSpeech_ProperNoun:       str = @"Proper Noun";       break;
      case WKVocabulary_PartOfSpeech_Expression:       str = @"Expression";        break;
      case WKVocabulary_PartOfSpeech_Adjective:        str = @"Adjective";         break;
      case WKVocabulary_PartOfSpeech_Interjection:     str = @"Interjection";      break;
      case WKVocabulary_PartOfSpeech_Counter:          str = @"Counter";           break;
      case WKVocabulary_PartOfSpeech_Pronoun:          str = @"Pronoun";           break;
      case WKVocabulary_PartOfSpeech_Conjunction:      str = @"Conjunction";       break;
    }
    [parts addObject:str];
  }];
  return [parts componentsJoinedByString:@", "];
}

@end

@implementation WKAssignment (Convenience)

- (bool)isLessonStage {
  return !self.hasStartedAt && self.srsStage == 0;
}

- (bool)isReviewStage {
  return self.hasAvailableAt && self.srsStage != 0;
}

- (NSDate *)availableAtDate {
  return [NSDate dateWithTimeIntervalSince1970:self.availableAt];
}

- (NSDate *)startedAtDate {
  return [NSDate dateWithTimeIntervalSince1970:self.startedAt];
}

- (NSDate *)passedAtDate {
  return [NSDate dateWithTimeIntervalSince1970:self.passedAt];
}

@end

@implementation WKProgress (Convenience)

- (NSString *)reviewFormParameters {
  return [NSString stringWithFormat:@"%d%%5B%%5D=%@&%d%%5B%%5D=%@",
          self.assignment.subjectId, self.hasMeaningWrong ? (self.meaningWrong ? @"1" : @"0") : @"",
          self.assignment.subjectId, self.hasReadingWrong ? (self.readingWrong ? @"1" : @"0") : @""];
}

- (NSString *)lessonFormParameters {
  return [NSString stringWithFormat:@"keys%%5B%%5D=%d", self.assignment.subjectId];
}

@end

@implementation WKUser (Convenience)

- (NSDate *)startedAtDate {
  return [NSDate dateWithTimeIntervalSince1970:self.startedAt];
}

@end
