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

class pc_EventHandler : EventHandler
{

  // public: ///////////////////////////////////////////////////////////////////

  override
  void WorldTick()
  {
    if (!_isInitialized) { initialize(); }
    prepareProjection();
  }

  override
  void RenderOverlay(RenderEvent event)
  {
    if (!_isInitialized || !_isPrepared) { return; }

    PlayerInfo player = players[consolePlayer];

    loadTarget(event.viewAngle, event.viewPitch);
    loadCrosshair(player);
    drawCrosshair(player, event);
  }

  // private: //////////////////////////////////////////////////////////////////

  private
  void initialize()
  {
    _glProjection  = new("Le_GlScreen");
    _swProjection  = new("Le_SwScreen");
    _cvarRenderer  = Cvar.GetCvar("vid_rendermode", players[consolePlayer]);

    _isInitialized = true;
  }

  private
  void prepareProjection ()
  {
    if(_cvarRenderer)
    {
      switch (_cvarRenderer.GetInt())
      {
      default:
        _projection = _glProjection;
        break;

      case 0:
      case 1:
        _projection = _swProjection;
        break;
      }
    }
    else
    {
      console.printf("warning, cannot get render mode");
      _projection = _glProjection;
    }

    _isPrepared = (_projection != NULL);
  }

  private
  void loadTarget(double angle, double pitch) const
  {
    PlayerPawn a = players[consolePlayer].mo;
    pitch = a.AimTarget() ? a.BulletSlope(NULL, ALF_PORTALRESTRICT) : pitch;

    FLineTraceData data;
    bool hit = a.LineTrace(angle, 4000.0, pitch, lFlags, a.AttackZOffset + a.height / 2, 0, 0, data);
    if (hit) { _targetPos = data.hitlocation; }
  }

  // private: //////////////////////////////////////////////////////////////////

  private ui
  void drawCrosshair(PlayerInfo player, RenderEvent event)
  {
    if (  !_isCrossExisting
       || gamestate == GS_TITLELEVEL
       || player.mo.health <= 0
       || automapactive
       )
    {
      return;
    }

    int screenWidth  = Screen.GetWidth();
    int screenHeight = Screen.GetHeight();

    double size = (crosshairscale > 0.0f)
                ? screenHeight * crosshairscale / 200.0
                : 1.0;

    if (crosshairgrow) { size *= StatusBar.CrosshairSize; }

    Vector2 textureSize = TexMan.GetScaledSize(_crosshairTexture);
    int width  = int(textureSize.x * size);
    int height = int(textureSize.y * size);

    int crossColor;

    if (crosshairhealth)
    {
      int health = scale(player.health, 100, getDefaultHealth(player));

      if (health >= 85)
      {
        crossColor = 0x00ff00;
      }
      else
      {
        int red;
        int green;

        health -= 25;
        if (health <  0) { health = 0; }
        if (health < 30)
        {
          red   = 255;
          green = health * 255 / 30;
        }
        else
        {
          red   = (60 - health) * 255 / 30;
          green = 255;
        }
        crossColor = (red<<16) | (green<<8);
      }
    }
    else
    {
      crossColor = crosshaircolor;
    }

    _projection.CacheResolution();
    _projection.CacheFov(player.fov);
    _projection.OrientForRenderOverlay(event);
    _projection.BeginProjection();

    _projection.ProjectWorldPos(_targetPos);

    Le_Viewport viewport;
    viewport.FromHud();

    //Vector2 screenPos = _projection.ProjectToScreen();
    Vector2 drawPos = viewport.SceneToWindow(_projection.ProjectToNormal());

    if(!_projection.IsInFront()) { return; } // should never happen for crosshair, though.

    Screen.DrawTexture( _crosshairTexture
                      , false
                      , screenWidth / 2
                      , drawPos.y
                      , DTA_DestWidth    , width
                      , DTA_DestHeight   , height
                      , DTA_AlphaChannel , true
                      , DTA_KeepRatio    , true
                      , DTA_FillColor    , crossColor & 0xFFFFFF
                      );
  }

  private ui
  void loadCrosshair(PlayerInfo player)
  {
    int num = 0;

    if (  !crosshairforce
       && NULL != player.camera
       && NULL != player.camera.player
       && NULL != player.camera.player.readyWeapon
       )
    {
      num = player.camera.player.readyWeapon.crosshair;
    }
    if (num == 0)
    {
      num = crosshair;
    }
    if (_crosshairnum == num && _isCrossExisting)
    {
      return;
    }

    if (num == 0)
    {
      _crosshairNum    = 0;
      _isCrossExisting = false;
      return;
    }
    if (num < 0)
    {
      num = -num;
    }
    string size = (Screen.GetWidth() < 640) ? "S" : "B";

    string texName = String.Format("XHAIR%s%d", size, num);
    TextureID texId = checkTexture(texName);
    if (!texId.isValid())
    {
      texName = String.Format("XHAIR%s1", size);
      texId = checkTexture(texName);
      if (!texId.isValid())
      {
        texId = checkTexture("XHAIRS1");
      }
    }

    _crosshairNum     = num;
    _crosshairTexture = texId;
    _isCrossExisting  = true;
  }

  private ui
  TextureId checkTexture(string name)
  {
    return TexMan.CheckForTexture( name
                                 , TexMan.Type_MiscPatch
                                 , TexMan.TryAny | TexMan.ShortNameOnly
                                 );
  }

  // private: //////////////////////////////////////////////////////////////////

  private ui static
  int scale(int value, int scaleMax, int valueMax)
  {
    return value * scaleMax / valueMax;
  }

  private ui static
  int getDefaultHealth(PlayerInfo player)
  {
    class<PlayerPawn> type = player.mo.GetClassName();
    let default = GetDefaultByType(type);
    return default.health;
  }

  // private: //////////////////////////////////////////////////////////////////

  private Vector3        _targetPos;

  private ui int         _crosshairNum;
  private ui bool        _isCrossExisting;
  private ui TextureID   _crosshairTexture;

  private transient bool _isInitialized;
  private transient bool _isPrepared;
  private transient Cvar _cvarRenderer;

  private Le_ProjScreen  _projection;
  private Le_GlScreen    _glProjection;
  private Le_SwScreen    _swProjection;

  // private: //////////////////////////////////////////////////////////////////

  const lFlags = LAF_NOIMPACTDECAL | LAF_NORANDOMPUFFZ;

} // class pc_EventHandler : EventHandler
