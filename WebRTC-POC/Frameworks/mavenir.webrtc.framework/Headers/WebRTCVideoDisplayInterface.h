#ifndef WEBRTCVIDEODISPLAYINTERFACE_H
#define WEBRTCVIDEODISPLAYINTERFACE_H

class WebRTCVideoDisplayInterface
{
	public:
		virtual ~WebRTCVideoDisplayInterface();

	protected:
		WebRTCVideoDisplayInterface();

	public:
		virtual void mavSetPreview( void* view ) = 0;
		virtual void mavSetRemoteVideoView( void* view, int width, int height ) = 0;

	private:
		WebRTCVideoDisplayInterface(const WebRTCVideoDisplayInterface&);
		const WebRTCVideoDisplayInterface& operator=(const WebRTCVideoDisplayInterface&);
};

#endif // WEBRTCVIDEODISPLAYINTERFACE_H
