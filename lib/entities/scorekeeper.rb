class Scorekeeper
  UPPER_MOVES = [:ones, :twos, :threes, :fours, :fives, :sixes]
  LOWER_MOVES = [:three_of_a_kind, :four_of_a_kind, :full_house,
                 :small_straight, :large_straight, :yahtzee, :chance]

  def initialize(x, y)
    @moves = Hash.new
    (UPPER_MOVES + LOWER_MOVES).each { |move| @moves[move] = Move.new(move)}
    @sprite = Gosu::Image.new($window, Utils.media_path('score.jpg'), false)
    @x = x
    @y = y
    init_clickables
    @font = Gosu::Font.new(20)
  end

  def moves_made
    moves_made = 0
    (UPPER_MOVES + LOWER_MOVES).each {|move| moves_made += 1 if !!@moves[move].score}
    moves_made
  end

  def inform_dice(dice)
    @dice = dice
  end

  def handle_click
    # Implement yahtzee bonus checker here
    @clickables.each { |clickable| @moves[clickable.move_type].make_and_score(@dice) if clickable.clicked? }
  end

  def update
  end

  def draw
    @sprite.draw(@x, @y, 0)

    (UPPER_MOVES).each_with_index {|move, index|
      if @moves[move].score then
          @font.draw("#{@moves[move].score}", 240, 25 * index + 35, 0, 1.0, 1.0, Gosu::Color::BLACK)
      else
        @font.draw("#{@moves[move].make(@dice)}", 240, 25 * index + 35, 0, 1.0, 1.0, Gosu::Color::RED)
      end
     }

     @font.draw("#{upper_score_raw}", 240, 190, 0, 1.0, 1.0, Gosu::Color::BLACK)
     @font.draw("#{upper_bonus}", 240, 215, 0, 1.0, 1.0, Gosu::Color::BLACK)
     @font.draw("#{upper_score_raw + upper_bonus}", 240, 240, 0, 1.0, 1.0, Gosu::Color::BLACK)

     (LOWER_MOVES).each_with_index {|move, index|
       if @moves[move].score then
           @font.draw("#{@moves[move].score}", 240, 25 * index + 290, 0, 1.0, 1.0, Gosu::Color::BLACK)
       else
         @font.draw("#{@moves[move].make(@dice)}", 240, 25 * index + 290, 0, 1.0, 1.0, Gosu::Color::RED)
       end
      }

      # Yahtzee bonuses
      @font.draw("#{lower_score}", 240, 520, 0, 1.0, 1.0, Gosu::Color::BLACK)
      @font.draw("#{upper_score_raw + upper_bonus}", 240, 545, 0, 1.0, 1.0, Gosu::Color::BLACK)
      @font.draw("#{total_score}", 240, 570, 0, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def total_score
    upper_score_raw + upper_bonus + lower_score
  end

  def game_over?
    (UPPER_MOVES + LOWER_MOVES).each { |move| if !@moves[move].score then return false end}
    return true
  end

  private

  def init_score_ui

  end

  def init_clickables
    w = 110
    h = 22
    x = 6
    y_positions = [32, 58, 84, 110, 135, 159, 289, 315, 341, 366, 392, 416, 443]
    @clickables = Array.new
    (UPPER_MOVES + LOWER_MOVES).each_with_index { |move, i| @clickables << Clickable.new(x, y_positions[i], w, h, move) }
  end

  def upper_moves
    @moves.select {|name, move| UPPER_MOVES.include? name}
  end

  def lower_moves
    @moves.select {|name, move| LOWER_MOVES.include? name}
  end

  def subtotal(move_set)
    move_set.map {|name, move| move.score}.inject(0){|total, val| total + (val.nil? ? 0 : val)}
  end

  def upper_score_raw
    subtotal(upper_moves)
  end

  def upper_bonus
    upper_score_raw >= 63 ? 35 : 0
  end

  def lower_score
    subtotal(lower_moves)
  end


end
