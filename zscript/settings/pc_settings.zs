/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
 *
 * This file is a part of Precise Crosshair.
 *
 * Precise Crosshair is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Precise Crosshair is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Precise Crosshair.  If not, see <https://www.gnu.org/licenses/>.
 */

class pc_Settings : pc_SettingsPack
{

  pc_Settings init(PlayerInfo player)
  {
    _player = player;
    return self;
  }

  // public: ///////////////////////////////////////////////////////////////////

  bool isFlipX() { checkInit(); return _flipX.value(); }
  bool isFlipY() { checkInit(); return _flipY.value(); }

  // private: //////////////////////////////////////////////////////////////////

  private
  void checkInit()
  {
    if (!_isInitialized)
    {
      push(_flipX = new("pc_BoolSetting").init("pc_flip_x", _player));
      push(_flipY = new("pc_BoolSetting").init("pc_flip_y", _player));
      _isInitialized = true;
    }
  }

  // private: //////////////////////////////////////////////////////////////////

  private pc_BoolSetting _flipX;
  private pc_BoolSetting _flipY;

  private PlayerInfo     _player;
  private transient bool _isInitialized;

} // class pc_Settings : pc_SettingsPack