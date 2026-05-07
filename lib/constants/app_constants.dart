
class AppConstants {
  
  static const Map<String, int> letterPoints = {
    'A': 1, 'B': 3, 'C': 4, 'Ç': 4, 'D': 3, 'E': 1,
    'F': 7, 'G': 5, 'Ğ': 8, 'H': 5, 'I': 2, 'İ': 1,
    'J': 10, 'K': 1, 'L': 1, 'M': 2, 'N': 1, 'O': 2,
    'Ö': 7, 'P': 5, 'R': 1, 'S': 2, 'Ş': 4, 'T': 1,
    'U': 2, 'Ü': 3, 'V': 7, 'Y': 3, 'Z': 4,
  };

 
  static const List<String> highFreqLetters = ['A', 'E', 'İ', 'L', 'R', 'N'];
  
  static const List<String> midFreqLetters = ['K', 'M', 'T', 'S', 'Y', 'D'];
  
  static const List<String> lowFreqLetters = [
    'B', 'C', 'Ç', 'G', 'H', 'I', 'O', 'Ö', 'P', 'Ş',
    'U', 'Ü', 'Z', 'F', 'V', 'Ğ', 'J',
  ];

  
  static const int highFreqWeight = 50;  
  static const int midFreqWeight = 35;  
  static const int lowFreqWeight = 15;   

 
  static const int gridSizeEasy = 10;    
  static const int gridSizeMedium = 8;   
  static const int gridSizeHard = 6;    

  
  static const int movesEasy = 25;
  static const int movesMedium = 20;
  static const int movesHard = 15;

 
  static const int minWordLength = 3;

  
  static const int powerRowClearLength = 4;
  static const int powerBombLength = 5;
  static const int powerColumnClearLength = 6;
  static const int powerMegaLength = 7;

  
  static const int jokerFishPrice = 100;          
  static const int jokerWheelPrice = 200;         
  static const int jokerLollipopPrice = 75;       
  static const int jokerSwapPrice = 125;          
  static const int jokerShufflePrice = 300;       
  static const int jokerPartyPrice = 400;         

  
  static const int initialGold = 999999;

  
  static const String keyUsername = 'username';
  static const String keyGold = 'gold';
  static const String keyOwnedJokers = 'owned_jokers';
  static const String keyGameHistory = 'game_history';

  
  static const String dictionaryPath = 'assets/turkce_kelimeler.txt';
}


enum Difficulty {
  easy,    
  medium,  
  hard,    
}


enum JokerType {
  fish,        
  wheel,       
  lollipop,    
  swap,        
  shuffle,     
  party,      
}


enum SpecialPower {
  none,
  rowClear,      
  bomb,          
  columnClear,   
  mega,          
}



