
#ifndef WEBRTCAPPSHAREDISPLAYINTERFACE_H
#define WEBRTCAPPSHAREDISPLAYINTERFACE_H

#include <list>

class WebRTCAppShareDisplayInterface
{
public:
	virtual ~WebRTCAppShareDisplayInterface();
	
protected:
	WebRTCAppShareDisplayInterface();
	
public:
	virtual void mavSetAppShareView( void* view ) = 0;
	virtual bool mavStartEditShareSession() = 0;
	virtual void mavStopEditShareSession() = 0;
	virtual void mavShowKeyboard() = 0;
	virtual void mavHideKeyboard() = 0;
private:
	WebRTCAppShareDisplayInterface(const WebRTCAppShareDisplayInterface&);
	const WebRTCAppShareDisplayInterface& operator=(const WebRTCAppShareDisplayInterface&);
};

#endif // WEBRTCAPPSHAREDISPLAYINTERFACE_H
