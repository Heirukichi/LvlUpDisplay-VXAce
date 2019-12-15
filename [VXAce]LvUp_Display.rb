#==============================================================================
# HEIRUKICHI - LEVEL UP STATS WINDOW
#==============================================================================
# Author: Heirukichi
# - Version 1.1.0
# - Last update: 12-15-2019 [MM-DD-YYYY]
# - Required: Trihan's Individual Experience Display
#==============================================================================
# DESCRIPTION
#------------------------------------------------------------------------------
# With this script it is possible to show stats window at the end of each
# battle if an actor gains one level.
#==============================================================================
# TERMS OF USE
#------------------------------------------------------------------------------
# This script is under the GNU General Public License v3.0. This means that:
# - You are free to use this script in both commercial and non-commercial games
#   as long as you give proper credits to me (Heirukichi) and provide a link to
#   my website;
# - You are free to modify this script as long as you do not pretend you wrote
#   this and you distribute it under the same license as the original.
#
# You can review the full license here:
# https://www.gnu.org/licenses/gpl-3.0.html
#
# In addition I'd like to keep track of games where my scripts are used so,
# even if this is not mandatory, I'd like you to inform me and send me a link
# when a game including my script is published.
# As I said, this is not mandatory but it really helps me and it is much
# appreciated.
#
# IMPORTANT NOTICE:
# If you want to distribute this code, feel free to do it, but provide a link
# to my website instead of pasting my script somewhere else.
#------------------------------------------------------------------------------
# If you are using this script, please keep in mind that the required script is
# a private script written for Kes (ksjp17). You CANNOT use that script if you
# are not Kes (ksjp17). If you want to use this script in your project and you
# are not Kes (ksjp17) you have to edit this script so that it can work without
# Trihan's script.
#==============================================================================
# INSTRUCTIONS
#------------------------------------------------------------------------------
# Copy/paste this script in your project below Matetrials. Be sure to paste it
# BELOW Trihan's script.
# You can configure this script changing values in the HRK_WLVLUP module.
# Detailed information on each one of those values can be found in the module
# itself.
#==============================================================================
$imported = {} if $imported.nil?
$imported["Heirukichi-LvUP"] = true
#------------------------------------------------------------------------------
# ** HRK_WLVLUP module
#------------------------------------------------------------------------------
module HRK_WLVLUP
  #============================================================================
  # Font size when displaying increased parameters after a level up.
  # Default is 14.
  #============================================================================
  FONT_SIZE = 14
  #============================================================================
  # Change the following values to be what you want to be displayed in the
  # window at the end of each battle. The "%d" in NORMAL_EXP_MESSAGE represents
  # the amount of exp you get. Do not remove it.
  #============================================================================
  NORMAL_EXP_MESSAGE = "%d EXP"
  LVL_UP_MESSAGE = "LEVEL UP!"
  #============================================================================
  # Here you can change how stats are displayed when leveling up. OLD_NEW_STAT
  # has three main components: the first "%d" represents the new value (current
  # level) while the second one represents the increment for that parameter.
  # Anything between those can be changed to be something you like more.
  # In STAT_NAMES you can change the name displayed for each stat when leveling
  # up. You can change MHP to HP, AGI to SPE and so on, up to you. Just
  # remember to avoid changing their order.
  #============================================================================
  OLD_NEW_STAT = "%d(+%d)"
  STAT_NAMES = ["HP", "MP", "ATK", "DEF", "MAT", "MDF", "AGI", "LUK"]
  #============================================================================
  # The following array contains parameters you want to hide when leveling up.
  # To hide a certain parameter add its parameter ID (same as those used when
  # writing battle formulae) in the array. To hide multiple parameters separate
  # them with a comma. Default is an empty array.
  #----------------------------------------------------------------------------
  # Example:
  # LVL_UP_HIDDEN_STATS = [0] <- this hides MHP
  #----------------------------------------------------------------------------
  # To check parameters ID you can press F1 and check RPG::Class in the index.
  #============================================================================
  LVL_UP_HIDDEN_STATS = []
  #============================================================================
  # This represents the amount of frames necessary to read character stats when
  # leveling up. After this amount of time the stats window disappear withuot
  # any input from the player. However, the player can still press a certain
  # button to let the window disappear before the time expires. Default buttons
  # are :A, :B and :C.
  # When showing a level up window, this value is multiplied by the number of
  # party members who gained a level, allowing the player to read what is
  # written in each window.
  #============================================================================
  WAIT_FRAMES = 800
  #============================================================================
  # The following string is displayed when a new skill is learned. The first %s
  # represents the actor's name, the second %s is for the skill name.
  #============================================================================
  SKILL_LEARNED = "%s learned %s!"
  #============================================================================
  # Set the symbols used to skip level up stats here. Default are [:A, :B, :C]
  #============================================================================
  SKIP_STATS = [:A, :B, :C]
  #----------------------------------------------------------------------------
  # ** HRK_WLVLUP::DEBUG module
  #----------------------------------------------------------------------------
  module DEBUG
    # Set this value to false if you do not want to debug the code settings
    ACTIVE = true
    #==========================================================================
    # Do not modify after this point unless you know what you are doing. Any
    # change in the code below can prevent the whole script from working.
    #--------------------------------------------------------------------------
    # * Pressed Button
    #--------------------------------------------------------------------------
    def self.display_button(button)
      return unless ACTIVE
      puts "Button #{button} is being pressed."
    end # Pressed Button
    #--------------------------------------------------------------------------
    # * Wait Time
    #--------------------------------------------------------------------------
    def self.display_wait_time(t)
      return unless ACTIVE
      puts "Current waiting time: #{t}"
    end # Wait Time
    #--------------------------------------------------------------------------
    # * Exit Message
    #--------------------------------------------------------------------------
    def self.display_stats_exit_message
      return unless ACTIVE
      return if @time.nil?
      puts "Closing level up stats window. Time: #{@time} frames."
    end # Exit Message
    #--------------------------------------------------------------------------
    # * Set Wait Time
    #--------------------------------------------------------------------------
    def self.set_wait_time(t)
      return unless ACTIVE
      @time = t
    end # Set Wait Time
    #--------------------------------------------------------------------------
    # * Increase Wait Time
    #--------------------------------------------------------------------------
    def self.increase_wait_time
      return unless ACTIVE
      return if @time.nil?
      @time += 1
    end # Increase Wait Time     
  end # end of HRK_WLVLUP::DEBUG module
  #----------------------------------------------------------------------------
  # ** HRK_WLVLUP::Window_LVLUP module
  #----------------------------------------------------------------------------
  module Window_LVLUP
    #--------------------------------------------------------------------------
    # * Window Height
    #--------------------------------------------------------------------------
    def self.height(win)
      win.line_height * 8 - HRK_WLVLUP::LVL_UP_HIDDEN_STATS.length
    end # Window Height
    #--------------------------------------------------------------------------
    # * Stat String
    #--------------------------------------------------------------------------
    def self.stat_old_new(id)
      return "" if HRK_WLVLUP::LVL_UP_HIDDEN_STATS.include?(id)
      sprintf("%s %s", HRK_WLVLUP::STAT_NAMES[id], OLD_NEW_STAT)
    end # Stat String
    #--------------------------------------------------------------------------
    # * Skip Stats?
    #--------------------------------------------------------------------------
    def self.skip_stats?
      result = false
      HRK_WLVLUP::SKIP_STATS.each do |button|
          HRK_WLVLUP::DEBUG.display_button(button) if Input.press?(button)
          result = true if Input.trigger?(button)
      end
      result
    end # Skip Stats?
  end # end of HRK_WLVLUP::Window_LVLUP module
end # end of HRK_WLVLUP module
#------------------------------------------------------------------------------
# ** Window_ExpInfo class
#------------------------------------------------------------------------------
class Window_ExpInfo < Window_Base
  #----------------------------------------------------------------------------
  # * Level Up Message
  #----------------------------------------------------------------------------
  def hrk_wlvlup_msg
    HRK_WLVLUP::LVL_UP_MESSAGE
  end # Level Up Message
  #----------------------------------------------------------------------------
  # * Exp Amount Message
  #----------------------------------------------------------------------------
  def hrk_wlvlup_xpmsg(amount)
    sprintf(HRK_WLVLUP::NORMAL_EXP_MESSAGE, amount.to_i)
  end # Exp Amount MEssage
  #----------------------------------------------------------------------------
  # * Refresh
  #----------------------------------------------------------------------------
  alias hrk_wlvlup_refresh_old    refresh
  def refresh
    contents.clear
    actor = $game_party.members[@index]
    xp_amount = $game_troop.exp_total * actor.final_exp_rate
    if BONUSEXP && $game_party.members[@index].state?(BonusEXPState)
      xp_amount += (actor.level * (rand(MutiplierRange) + MutiplierMin))
    end
    lvup = ((actor.exp + xp_amount) >= actor.next_level_exp)
    msg = (lvup ? hrk_wlvlup_msg : hrk_wlvlup_xpmsg(xp_amount))
    draw_text(0, 0, contents.width, line_height, "#{msg}")
  end # Refresh
end # end of Window_ExpInfo class
#------------------------------------------------------------------------------
# ** Scene_Battle class
#------------------------------------------------------------------------------
class Scene_Battle
  #============================================================================
  # In this class I used a few eval methods. I did this mostly because the
  # original script used this way and this script had to be compatible with
  # the original one.
  #----------------------------------------------------------------------------
  # ! WARNING !
  #----------------------------------------------------------------------------
  # Be careful when handling it. Reading this code might be very diffucult.
  #============================================================================
  # * Create Experience Windows
  #----------------------------------------------------------------------------
  alias hrk_wlvlup_create_exp_windows_old create_exp_windows
  def create_exp_windows(*args, &block)
      hrk_wlvlup_create_exp_windows_old(*args, &block)
      create_level_up_windows
  end # Create Experience Windows
  #----------------------------------------------------------------------------
  # * Create Level Up Windows
  #----------------------------------------------------------------------------
  def create_level_up_windows
    return if @exp_window_0.nil?
    dummy_window = @exp_window_0
    win_name = "@lvup_window_%d"
    $game_party.members.each.with_index do |actor, i|
      wn = sprintf(win_name, i)
      wx = eval("@exp_window_#{i}.x")
      wh = dummy_window.height + HRK_WLVLUP::Window_LVLUP.height(dummy_window)
      wy = dummy_window.y - wh + dummy_window.height
      ww = dummy_window.width
      instance_variable_set(wn, Window_Base.new(wx, wy, ww, wh))
      eval("#{wn}.openness = 0")
      wtxt = "#{HRK_WLVLUP::LVL_UP_MESSAGE}"
      txth = eval("#{wn}.padding - #{wn}.height/2")
      eval("#{wn}.draw_text(0, txth, #{wn}.contents.width, wh, wtxt)")
      cc = $data_classes[actor.class_id]
      lh = eval("#{wn}.line_height")
      (0..7).each do |id|
        txth += lh
        txt_new = HRK_WLVLUP::Window_LVLUP.stat_old_new(id)
        old_value = cc.params[id, actor.level]
        new_value = cc.params[id, actor.level + 1]
        new_value = old_value if new_value.nil?
        wtxt = sprintf(txt_new, new_value, new_value - old_value)
        eval("#{wn}.contents.font.size = #{HRK_WLVLUP::FONT_SIZE}")
        eval("#{wn}.draw_text(0, txth, #{wn}.contents.width, wh, wtxt)")
      end
    end
  end # Create Level Up Windows
  #----------------------------------------------------------------------------
  # * Show Level Up Window
  #----------------------------------------------------------------------------
  def hrk_lvlup_show_lvl_up_window(id)
    eval("@lvup_window_#{id}.open")
  end # Show Level Up Window
  #----------------------------------------------------------------------------
  # * Open Experience Window
  #----------------------------------------------------------------------------
  def hrk_lvlup_show_xp_window(id)
    eval("@exp_window_#{id}.open")
    eval("@exp_window_#{id}.refresh")
  end # Show Experience Window
  #----------------------------------------------------------------------------
  # * Close Experience Window
  #----------------------------------------------------------------------------
  def hrk_lvlup_close_exp_windows
    $game_party.members.each_index do |id|
      eval("@exp_window_#{id}.close")
      eval("@lvup_window_#{id}.close")
    end
  end # Close Experience Window
  #----------------------------------------------------------------------------
  # * Show Experience Windows
  #----------------------------------------------------------------------------
  alias hrk_wlvlup_show_exp_windows_old    show_exp_windows
  def show_exp_windows
    party_members_leveling_up = 0
    $game_party.members.each.with_index do |actor, i|
      xp = $game_troop.exp_total * $game_party.members[i].final_exp_rate
      lvlup = ((actor.exp + xp) >= actor.next_level_exp)
      party_members_leveling_up += 1 if lvlup
      lvlup ? hrk_lvlup_show_lvl_up_window(i) : hrk_lvlup_show_xp_window(i)
    end
    party_members_leveling_up *= HRK_WLVLUP::WAIT_FRAMES
    c_wait_time = [party_members_leveling_up, 80].max
    HRK_WLVLUP::DEBUG.display_wait_time(c_wait_time)
    wait(220)
    HRK_WLVLUP::DEBUG.set_wait_time(220)
    c_wait_time.times do
      break if HRK_WLVLUP::Window_LVLUP.skip_stats?
      abs_wait(1)
      HRK_WLVLUP::DEBUG.increase_wait_time
    end
    HRK_WLVLUP::DEBUG.display_stats_exit_message
    hrk_lvlup_close_exp_windows
  end # Show Experience windows
end # end of Scene_Battle class
#------------------------------------------------------------------------------
# ** Game_Actor class
#------------------------------------------------------------------------------
class Game_Actor
  #----------------------------------------------------------------------------
  # * Display Level Up
  #----------------------------------------------------------------------------
  alias hrk_lvlup_display_level_up_old    display_level_up
  def display_level_up(new_skills)
    if ($imported["Heirukichi-LvUP"] && $game_party.in_battle)
      $game_message.new_page
      new_skills.each do |skill|
        $game_message.add(sprintf(HRK_WLVLUP::SKILL_LEARNED, @name, skill.name))
      end
    else
      hrk_lvlup_display_level_up_old(new_skills)
    end
  end # Display Level Up
end # end of Game_Actor class