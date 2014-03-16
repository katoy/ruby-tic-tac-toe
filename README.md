
[![Build Status](https://travis-ci.org/katoy/ruby-tic-tac-toe.png?branch=master)](https://travis-ci.org/katoy/ruby-tic-tac-toe)
[![Dependency Status](https://gemnasium.com/katoy/ruby-tic-tac-toe.png)](https://gemnasium.com/katoy/ruby-tic-tac-toe)
[![Coverage Status](https://coveralls.io/repos/katoy/ruby-tic-tac-toe/badge.png)](https://coveralls.io/r/katoy/ruby-tic-tac-toe)

book "Computer Science Programming Basics in Ruby"  http://shop.oreilly.com/product/0636920028192.do  
の中の  tic-tac-toe のコード。  

 guard + rspec の環境を整え、リファクタリングしていく。
  

1. $ bundle install  
2. $ guard  
3. edit source.  
   auto runninng rspec when save file.  
4. open coverage/rcov/index.html, yuo can see coverage.  
  
5. $ ruby lib/tictactoe.rb
  
6. $ rubocop

For debug, put "binding.pry" in *.rb (lib/**.rb, spec/**.rb)  

TODO:

Use minmax.  

