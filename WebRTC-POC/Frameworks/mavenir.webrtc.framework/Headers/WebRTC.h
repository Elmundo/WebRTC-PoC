
#ifndef WebRTC_H
#define WebRTC_H

#include <string>
#include <list>
#include <map>

#include "WebRTCCommon.h"

class WebRTCVideoDisplayInterface;
class WebRTCAppShareDisplayInterface;
class WebRTCWBDisplayInterface;
class WebRTC
{
public:
	static WebRTC& mavInstance();

	virtual WEBRTC_STATUS_CODE mavInitialize( const WebRTCConfig& config ) = 0;
	virtual WEBRTC_STATUS_CODE mavFinalize() = 0;

    //#ifdef DIGITS_OTT
    virtual WEBRTC_STATUS_CODE mavSendRegistrationInfo( const std::string& msisdn, const std::string& emailid, const std::string& lineid, const std::string& nativeline) = 0;
virtual WEBRTC_STATUS_CODE mavSendUnRegistrationInfo( const std::string& msisdn, const std::string& emailid, const std::string& lineid) = 0;
    virtual WEBRTC_STATUS_CODE digitsRegister( const std::string& fqdn, const std::string& authcode, const std::string& displayname, const std::string& friendlyname, const std::string& nativeline, const std::string& cwl	) = 0;
    virtual WEBRTC_STATUS_CODE digitsReRegistration(const std::string& nativeline) = 0;
//#endif
	virtual WEBRTC_STATUS_CODE mavRegister( const std::string& fqdn, const std::string& authcode, const std::string& displayname, const std::string& friendlyname, const std::string& nativeline, const std::string& cwl	) = 0;
	virtual WEBRTC_STATUS_CODE mavUnRegister( bool deactivate ) = 0;
	virtual WEBRTC_STATUS_CODE mavReRegister( const std::string& sessionid, const std::string& nativeline ) = 0;
	virtual WEBRTC_STATUS_CODE mavRegisterAgain( const std::string& session_info ) = 0;

	virtual WEBRTC_STATUS_CODE mavGetWRGToken( const std::string& sessionid, const std::string& clientid ) = 0;

	virtual WEBRTC_STATUS_CODE mavFetchAccessToken () = 0;
	virtual WEBRTC_STATUS_CODE mavSetAccessToken(const std::string& access_token, const std::string& refresh_token, const std::string& ttl) = 0;
	virtual WEBRTC_STATUS_CODE mavSetPushToken( const std::string&  pushtoken, const std::string&  deviceuuid, const std::string&  servicename, const std::string&  ostype  ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetupChat( const std::string& uri, std::string& sessionid, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavSendChat( const std::string& sessionid, const std::string& messageid, const std::string& message ) = 0;
	virtual WEBRTC_STATUS_CODE mavSendPMDisplayedStatus( const std::string& messageid ) = 0;
	virtual WEBRTC_STATUS_CODE mavSendChatReadStatus( const std::string& sessionid, const std::string& messageid ) = 0;
	virtual WEBRTC_STATUS_CODE mavEndChat( const std::string& sessionid ) = 0;
	
	virtual WEBRTC_STATUS_CODE mavEmergencyCallStart( const std::string& callid, const std::string& pidflo ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetupEmergencyChat( const std::string& sessionid, const std::string& pidflo ) = 0;

	virtual WEBRTC_STATUS_CODE mavCallStart( const std::string& uri, std::string& callid, bool isvideocall, const WEBRTC_AUDIO_DEVICE_TYPE& type, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallEnd( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallAccept( const std::string& callid, bool isvideocall, const WEBRTC_AUDIO_DEVICE_TYPE& type ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallReject( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallMute( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallUnmute( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallHold( const std::string& callid, bool releasedevice ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallUnhold( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallVideoResume( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallVideoPause( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallAddVideo( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallRemoveVideo( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavCallDTMF( const std::string& callid, char digit ) = 0;
	
	virtual WEBRTC_STATUS_CODE mavCallTransfer( const std::string&  callid, const std::string&  uri ) =0;
	virtual WEBRTC_STATUS_CODE mavCallTransferConsult( const std::string&  callid_1, const std::string&  callid_2 ) =0;

	virtual WEBRTC_STATUS_CODE mavSwitchDevice( const std::string&  callid, const std::string&  device ) =0;

	virtual WEBRTC_STATUS_CODE mavMeetingWave( const std::string& meetingid, const std::string& wave) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingLectureMode( const std::string& meetingid, const std::string& mode) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingScreenShareEnd( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingScreenShareAccept(const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavGetIMRN(const std::string& CgPn, const std::string& CdPn, const std::string& nativeline, const std::string& latitude, const std::string& longitude, const std::string& radius, const std::string& civicAddress ) = 0;
	
	virtual WEBRTC_STATUS_CODE mavCallUnMute( const std::string& callid ) = 0;

	virtual WEBRTC_STATUS_CODE mavSendFT( std::string& sessionid, const std::string& uri, const std::string& filename, const std::string& thumbnail_url, const std::string& file_url, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavSendFTReadStatus( const std::string& sessionid ) = 0;

	virtual WEBRTC_STATUS_CODE mavScreenShareEnd( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavScreenShareAccept( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavScreenShareReject( const std::string& callid ) = 0 ;

	virtual WEBRTC_STATUS_CODE mavFlipCamera( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingStart( const std::string& meetingid, const std::string& displayname, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingEnd( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAccept( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingReject( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAddAV( const std::string& meetingid, bool isvideo , const WEBRTC_AUDIO_DEVICE_TYPE& type ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingDropAV( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAddVideo( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingDropVideo( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingHoldAV( const std::string& meetingid, bool releasedevice = true ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingUnholdAV( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingSelfMute( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingSelfUnmute( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAddParty( const std::string& meetingid, const std::string& uri ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAddPartyDID( const std::string& meetingid, const std::string& did ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingPauseVideo( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingResumeVideo( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingChangeVideoLayout( const std::string& meetingid, const std::string& layout ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingVideoLayoutTransition( const std::string& meetingid, const std::string& page ) = 0;
	virtual WEBRTC_STATUS_CODE mavFlipCameraInMeeting( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetAudioOutputDevice( const WEBRTC_AUDIO_DEVICE_TYPE& devicetype ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetVideoDisplayInterface( const std::string& callid, WebRTCVideoDisplayInterface* videodisplay ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetAppShareDisplayInterface( const std::string& callid, WebRTCAppShareDisplayInterface* sharedisplay ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetMeetingVideoDisplayInterface( const std::string& meetingid, WebRTCVideoDisplayInterface* videodisplay ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetMeetingAppShareDisplayInterface( const std::string& meetingid, WebRTCAppShareDisplayInterface* sharedisplay ) = 0;

	virtual WEBRTC_STATUS_CODE mavScheduledMeetingJoin( const std::string& meetingid, const std::string& displayname, const std::string& password, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingExit( const std::string& meetingid, const std::string& option ) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingCallMe(const std::string& meetingid, const std::string& number) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingLock(const std::string& meetingid, bool lock) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingMuteParticipant(const std::string& meetingid, const std::string& participant) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingUnmuteParticipant(const std::string& meetingid, const std::string& participant) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingRemoveParticipant(const std::string& meetingid,  const std::string& participant) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingMuteAll(const std::string& meetingid) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingUnMuteAll(const std::string& meetingid) = 0;
	virtual WEBRTC_STATUS_CODE mavScheduledMeetingAddParty(const std::string& meetingid, const std::string& uri, const std::string& password ) = 0;
	virtual WEBRTC_STATUS_CODE mavGuestMode ( const std::string& cif_url ) = 0;
	virtual WEBRTC_STATUS_CODE mavFetchLogs ( const std::string& folder, const std::string& lineinfo, const std::string& cursor, int entries  ) = 0;
	virtual WEBRTC_STATUS_CODE mavFetchLogsDelta ( const std::string& folder, const std::string& date,const std::string& lineinfo, const std::string& cursor, int entries  ) = 0;
	virtual WEBRTC_STATUS_CODE mavDeleteLog (const std::string& folder, const std::string& logid) = 0;
	
	virtual WEBRTC_STATUS_CODE mavSetupWBSession ( const std::string& uri, std::string& callid,  const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavEndWBSession ( const std::string& callid ) = 0;
	virtual WEBRTC_STATUS_CODE mavAcceptWBSession ( const std::string& uri, const std::string& callid) = 0;
	virtual WEBRTC_STATUS_CODE mavRejectWBSession ( const std::string& uri, const std::string& callid) = 0;
	virtual WEBRTC_STATUS_CODE mavSetWBInterface (const std::string& callid, WebRTCWBDisplayInterface* canvas) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingRecordStart (const std::string& meetingid) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingRecordStop (const std::string& meetingid) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingRecordCancel (const std::string& meetingid) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingRecordingDelete (const std::string& meetingid, const std::string& clipid) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAddSFB ( const std::string& meetingid, const std::string& sfburl) = 0;
	virtual WEBRTC_STATUS_CODE mavUploadVMGreeting( const std::string& filename, const std::string& greetingtype, int duration, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingJoinWB ( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingLeaveWB ( const std::string& meetingid ) = 0;
	virtual WEBRTC_STATUS_CODE mavSetMeetingWBInterface ( const std::string& meetingid,WebRTCWBDisplayInterface* canvas ) = 0;
	
	virtual WEBRTC_STATUS_CODE mavStartGroupChat(const std::string& sessionid, const std::list<std::string>& participants, const std::string& lineinfo ) = 0;
	virtual WEBRTC_STATUS_CODE mavSendFileInGroupChat( std::string& sessionid, const std::string& filename, const std::string& thumb_url, const std::string& file_url ) = 0;
	
	virtual WEBRTC_STATUS_CODE mavMeetingOneWayVideo ( const std::string& meetingid, const std::string& status ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingAdmitParticipant ( const std::string& meetingid, const std::string& participantid, const std::string& allow ) = 0;
	virtual WEBRTC_STATUS_CODE mavMeetingChangeHost ( const std::string& meetingid, const std::string& uri) = 0;
	
	virtual const WEBRTC_STATE mavState() = 0;
	virtual const WebRTCConfig& mavConfig() = 0;

protected:
	WebRTC();

private:
	WebRTC(const WebRTC&);
	const WebRTC& operator=(const WebRTC&);
};

#endif // WebRTC_H
