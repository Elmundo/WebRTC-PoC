
#ifndef WEBRTCWBDISPLAYINTERFACE_H
#define WEBRTCWBDISPLAYINTERFACE_H
#include <string>
#include "WebRTCCommon.h"

 
class WebRTCWBDisplayInterface
{
public:
	virtual ~WebRTCWBDisplayInterface();
	
protected:
	WebRTCWBDisplayInterface();
	
public:
	virtual void mavSetWBView( void* view ) = 0;
	void mavSetDrawMode (bool mode);
	WBShape mavGetShapeAttributes() ;
	void mavSetShape(const std::string&  type);
	void mavSetLineColor(unsigned long color, const std::string& shapeid);
	void mavSetFillColor ( unsigned long color, const std::string& shapeid);
	void mavSetLineWidth (int width, const std::string& shapeid);
	void mavSetFont (const std::string& FontStyle, const std::string& FontName, int FontSize, unsigned long FontColor, const std::string& shapeid);
	void mavDeleteShape (const std::string& shapeid);
	void mavDeleteAllShapes();
	void mavSaveWB (const std::string& filename );
	void mavDrawShape(WBShape shape);
	
	virtual void mavOnShapeDrawn (const std::string& shapeid) = 0;
	virtual void mavOnShapeSelected (const std::string& shapeid ) = 0;
	virtual void mavOnShapeDeleted ( const std::string& shapeid ) = 0;
	virtual void mavOnAllShapesDeleted () = 0;
public:
	void* Canvas;
	
private:
	WebRTCWBDisplayInterface(const WebRTCWBDisplayInterface&);
	const WebRTCWBDisplayInterface& operator=(const WebRTCWBDisplayInterface&);
};
#endif // WEBRTCWBDISPLAYINTERFACE_H
