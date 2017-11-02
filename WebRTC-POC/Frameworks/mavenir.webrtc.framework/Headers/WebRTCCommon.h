
#ifndef WEBRTCCOMMON_H
#define WEBRTCCOMMON_H

#include <string>
#include <list>

typedef enum
{
	WEBRTC_STATE_IDLING,
	WEBRTC_STATE_PROCEEDING,
	WEBRTC_STATE_RECEDING,
	WEBRTC_STATE_ACTIVE
} WEBRTC_STATE;

typedef enum
{
	WEBRTC_STATUS_OK,
	WEBRTC_STATUS_FAILED,
	WEBRTC_STATUS_INVALIDSTATE,
	WEBRTC_STATUS_INVALIDCONFIG,
	WEBRTC_STATUS_MEMORYERROR,
	WEBRTC_STATUS_ACTIVATIONERROR,
	WEBRTC_STATUS_STARTUPERROR,
	WEBRTC_STATUS_NOTACTIVATED,
	WEBRTC_STATUS_OPERATIONFAILED,
	WEBRTC_STATUS_AUDIO_SESSION_EXISTS,
	WEBRTC_STATUS_TOO_MANY_SESSIONS,
	WEBRTC_STATUS_SHARING_SESSION_EXISTS,
	WEBRTC_STATUS_AVCONF_SESSION_EXISTS,
	WEBRTC_STATUS_MIC_BUSY
} WEBRTC_STATUS_CODE;

typedef enum
{
	WEBRTC_AUDIO_BLUETOOTH,
	WEBRTC_AUDIO_SPEAKER,
	WEBRTC_AUDIO_WIRED_HEADSET,
	WEBRTC_AUDIO_EAR_PIECE
} WEBRTC_AUDIO_DEVICE_TYPE;

typedef struct
{
	std::string	Uri;
	std::string	DisplayName;
} ParticipantList;

typedef struct
{
	std::string	Name;
	std::string	InstanceId;
} RegisteredDevices;

typedef struct
{
	std::string		uri;
	std::string		type;
	int			lineWidth;
	unsigned long		lineColor;
	unsigned long		fillColor;
	std::string 		FontStyle;
	std::string 		FontName;
	int			FontSize;
	unsigned long		FontColor;
	std::string		text;
}WBShape;

class WebRTCConfig
{
public:
	WebRTCConfig()
	{
		TurnServerIP = "";
		TurnServerUDPPort = 0;
	}
	
	WebRTCConfig(const WebRTCConfig& cfg)
	{
		TurnServerIP	 	= cfg.TurnServerIP;
		TurnServerUDPPort	= cfg.TurnServerUDPPort;
	}
	
	WebRTCConfig& operator= (const WebRTCConfig& cfg)
	{
		TurnServerIP	 	= cfg.TurnServerIP;
		TurnServerUDPPort	= cfg.TurnServerUDPPort;
		
		return *this;
	}
	
	std::string	TurnServerIP;
	int			TurnServerUDPPort;
};

#endif // WEBRTCCOMMON_H

