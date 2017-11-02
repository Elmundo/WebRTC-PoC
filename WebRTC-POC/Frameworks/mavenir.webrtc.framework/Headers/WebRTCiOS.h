#ifndef WEBRTCIOS_H
#define WEBRTCIOS_H

#import <Foundation/Foundation.h>

#include "WebRTCCommon.h"

@protocol WebRTCiOSDelegate <NSObject>
@required


- (void) mavOnReceivedRegisterSuccess : (std::string) did fid:(std::string) fid sessionid:(std::string) sessionid clientid:(std::string) clientid;
- (void) mavOnReceivedReRegisterSuccess : (std::string) did fid:(std::string) fid sessionid:(std::string) sessionid clientid:(std::string) clientid;
- (void) mavOnReceivedWRGToken : (std::string) wrgtoken;
- (void) mavOnReceivedAccessToken : (std::string) access_token refresh_token:(std::string) refresh_token ttl:(std::string) ttl status:(std::string) status;
- (void) mavOnReceivedRegisterError:(int)responsecode errorcode:(int)errorcode;
- (void) mavOnReceivedUnRegisterSuccess;
- (void) mavOnReceivedSessionInfo : (std::string) session_info;
- (void) mavOnReceivedSessionExpired;
- (void) mavOnFetchLogsResponse : (std::string) data folder:(std::string) folder lineinfo:(std::string)lineinfo status:(std::string) status cursor:(std::string)cursor;
- (void) mavOnSetupChatStatus : (std::string) sessionid status:(std::string) status;
- (void) mavOnSendChatNotification : (std::string)sessionid messageid:(std::string)messageid uri:(std::string)uri status:(std::string) status recvimid:(std::string)recvimid;
- (void) mavOnRecvChatNotification : (std::string) sessionid uri:(std::string) uri;
- (void) mavOnRecvChatDataNotification : (std::string) sessionid messageid:(std::string) messageid message:(std::string) message senderuri:(std::string) senderuri;
- (void) mavOnChatEndNotification : (std::string) sessionid;
- (void) mavOnReceivedNewCall : (std::string) uri callid:(std::string) callid LineInfo:(std::string) LineInfo;
- (void) mavOnReceivedNewVideoCall : (std::string) uri callid:(std::string) callid LineInfo:(std::string) LineInfo;
- (void) mavOnReceivedCallStatus : (std::string) callid statuscode:(int) statuscode;
- (void) mavOnReceivedCallActive : (std::string) callid;
- (void) mavOnReceivedVideoCallActive : (std::string) callid;
- (void) mavOnReceivedCallEnd : (std::string) callid;
- (void) mavOnReceivedCallRejected : (std::string) callid;
- (void) mavOnReceivedCallHold : (std::string) callid;
- (void) mavOnReceivedCallUnhold : (std::string) callid;
- (void) mavOnReceivedCallVideoAdded : (std::string) callid;
- (void) mavOnReceivedCallVideoDropped : (std::string) callid;

- (void) mavOnSendFTNotification : (std::string) sessionid status:(std::string) status uri:(std::string) uri imdnmessageid:(std::string)imdnmessageid;
- (void) mavOnRecvFTNotification : (std::string) sessionid uri:(std::string) uri filename:(std::string)filename thumbnail_url:(std::string)thumbnail_url file_url:(std::string)file_url imdnmessageid:(std::string)imdnmessageid;
- (void) mavOnReceivedNewScreenShare : (std::string) uri callid:(std::string) callid;
- (void) mavOnReceivedScreenShareActive : (std::string) callid;
- (void) mavOnReceivedScreenShareEnd : (std::string) callid;

- (void) mavOnStartMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnMeetingAcceptStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnMeetingEnded : (std::string) meetingid;
- (void) mavOnMeetingParticipantList : (std::string) meetingid participants:(std::list<ParticipantList>) participants;
- (void) mavOnReceivedMeetingRequest : (std::string) uri meetingid:(std::string) meetingid;
- (void) mavOnAddAudioVideoMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnDropAudioVideoMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnAddVideoMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnDropVideoMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnHoldMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnUnholdMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnChangeLayoutMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnLayoutTransitionMeetingStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnVideoLayoutMeetingStatus : (std::string) meetingid layout:(std::string) layout participants:(std::list<std::string>) participants nextscreen:(bool)nextscreen  prevscreen:(bool)prevscreen;
- (void) mavOnReceivedMeetingParticipantStatus : (std::string) meetingid uri:(std::string)uri display:(std::string)display status:(std::string) status;
- (void) mavOnMeetingAddPartyStatus : (std::string) meetingid participant:(std::string) participant status:(std::string) status;
- (void) mavOnMeetingAddSFBStatus : (std::string) meetingid sfburl:(std::string) sfburl status:(std::string) status;
- (void) mavOnReceivedScheduledMeetingRequest : (std::string) meetingid uri:(std::string) uri password:(std::string) password;
- (void) OnMavScheduledMeetingJoinStatus : (std::string) meetingid status:(std::string) status attendeeid:(std::string) attendeeid role:(std::string) role broadcast:(bool)broadcast lobby:(std::string) lobby;
- (void) OnMavScheduledMeetingCallMeStatus : (std::string) meetingid status:(std::string) status;
- (void) OnMavScheduledMeetingEnded : (std::string) meetingid;
- (void) OnMavScheduledMeetingLockStatus  : (std::string) meetingid status:(bool) status;
- (void) OnMavScheduledMeetingMuteParticipantStatus : (std::string) meetingid	participant:(std::string) participant status:(bool) status;
- (void) OnMavScheduledMeetingUnmuteParticipantStatus : (std::string) meetingid participant:(std::string) participant status:(bool) status;
- (void) OnMavScheduledMeetingRemoveParticipantStatus : (std::string) meetingid participant:(std::string) participant;
- (void) mavOnScheduledMeetingHostJoined : (std::string) meetingid uri:(std::string) uri;
- (void) OnMavUnRegisterStatus:(bool)status;
- (void) OnMavScheduledMeetingMuteAllStatus : (std::string) meetingid status:(bool) status;
- (void) OnMavScheduledMeetingUnMuteAllStatus : (std::string) meetingid status:(bool) status;
- (void) mavOnCallTransferStatus : (std::string) callid status:(std::string) status;
- (void) mavOnMeetingWaveStatus : (std::string) meetingid wave:(std::string) wave uri:(std::string) uri;
- (void) mavOnMeetingLectureModeStatus : (std::string) meetingid	mode:(std::string) mode;
- (void) mavOnMeetingScreenShareAvailable : (std::string) meetingid uri:(std::string) uri;
- (void) mavOnMeetingScreenShareStatus : (std::string) meetingid	status:(std::string) status;
- (void) mavOnRegisteredDevices : (std::list<RegisteredDevices>) devicelist;
- (void) mavOnMsgNotification : (std::string) number;
- (void) mavOnLogsNotification :(std::string) log;
- (void) mavOnLogDeleted : (std::string) folder logid:(std::string) logid;
- (void) mavOnReceivedIMRN : (std::string) imrn status:(std::string) status;
- (void) mavOnGuestModeResponse : (std::string) sessionid clientid:(std::string) clientid meetingid:(std::string) meetingid status:(std::string) status;

- (void) mavOnReceivedWBRequest : (std::string) uri callid:(std::string) callid;
- (void) mavOnReceivedWBStatus : (std::string) callid status:(std::string) status;
- (void) mavOnReceivedWBActive : (std::string) callid;
- (void) mavOnReceivedWBEnd : (std::string) callid;
- (void) mavOnReceivedWBRejected : (std::string) callid;
- (void) mavOnRecordingStatus : (std::string) meetingid uri:(std::string) uri status:(std::string) status;
- (void) mavOnRecordingInfo : (std::string) meetingid clipid:(std::string)clipid starttime:(std::string) starttime duration:(std::string) duration type:(std::string) type;
- (void) mavOnMeetingRecordingDeleteStatus : (std::string) meetingid clipid:(std::string) clipid status:(std::string) status;
- (void) mavOnUploadVMGreetingStatus : (std::string) status;

- (void) mavOnMeetingWBJoinStatus : (std::string) meetingid	status:(std::string) status;
- (void) mavOnMeetingWBLeaveStatus : (std::string) meetingid status:(std::string) status;
- (void) mavOnMeetingReceivedWBStatus : (std::string) meetingid status:(std::string) status;

- (void) mavOnGroupChatStatus : (std::string) sessionid status:(std::string) status;
- (void) mavOnGroupChatReceived : (std::string) sessionid participants:(std::list<std::string>) participants;
- (void) mavOnFetchLogsDeltaResponse :(std::string)data folder:(std::string)folder lineinfo:(std::string) lineinfo status:(std::string)status cursor:(std::string) cursor;

- (void) mavOnMeetingOneWayVideoStatus :(std::string)meetingid status:(std::string)status;
- (void) mavOnMeetingWaitingInLobby :(std::string)meetingid uri:(std::string)uri display:(std::string) display participantid:(std::string) participantid;
- (void) mavOnMeetingAdmitParticipantStatus :(std::string)meetingid participantid:(std::string)participantid allow:(std::string)allow;
- (void) mavOnMeetingAdmitParticipantStatus :(std::string)meetingid participantid:(std::string)participantid allow:(std::string)allow status:(std::string)status;
- (void) mavOnMeetingChangeHostStatus :(std::string)meetingid uri:(std::string)uri status:(std::string)status;
- (void) mavOnMeetingHostChanged :(std::string)meetingid uri:(std::string)uri;
- (void) mavOnReceivedPageModeData:(std::string)messagid textmsg:(std::string)textmsg senderaddress:(std::string)senderaddress;

-(void) mavLineInfo: (std::string) lineinfo;

@end

@interface WebRTCiOS : NSObject {
    id<WebRTCiOSDelegate> delegate;
}

@property (nonatomic, assign)   id<WebRTCiOSDelegate> delegate;
+(id) mavGetInstance;

@end

#endif
