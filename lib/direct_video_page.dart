//module: direct_video_page.dart
// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Ensure this is imported
import 'package:provider/provider.dart';

class DirectVideoPage extends StatefulWidget {
  const DirectVideoPage({super.key});
  @override
  _DirectVideoPageState createState() => _DirectVideoPageState();
}

class _DirectVideoPageState extends State<DirectVideoPage> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  final _firestore = FirebaseFirestore.instance;
  late User _user; //accessed in Build
  late String userId;
  
  @override
  void initState() {
    //print('_DirectVideoPageState:initState');
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initializeVideoRenderer().then((_) {
      _setupWebRTC();
    }).catchError((error) {
      print('Init fail: $error');
    });
  }
  @override
  void dispose() {
    //print('_DirectVideoPageState:dispose');
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream.dispose();
    _peerConnection.close();
    super.dispose();
  }
  //optional async initializer
  // Future<void> _initializeAsync() async {
  //     try {
  //         await _initializeVideoRenderer();
  //         await _setupWebRTC();
  //     } catch (error) {
  //         print('Initialization failed: $error');
  //     }
  // }

  Future<void> _initializeVideoRenderer() async {
    print('>>>___ _ in _DirectVideoPageState:_initializeVideoRender');
    await _localRenderer.initialize().then((_) => print('>>>___ local renderer initialized'));
    await _remoteRenderer.initialize().then((_) => print('>>>___ Remote renderer initialized'));//??? just adding remote like local
  }
  String videoRoomId = 'your_videoRoom_id'; // This should be set dynamically based on your app logic
  
  // =========== setupwebrtc ===========
  Future<void> _setupWebRTC() async {
      //print('_DirectVideoPageState:_setupWebRTC');
      //Request permissions for camera and microphone
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };
    //If you don't configure a TURN server or the credentials are incorrect, 
    //the WebRTC connection will still attempt to establish a connection using 
    //the STUN server. This means it may still work if the STUN server can 
    //resolve the NAT traversal. However, in cases where TURN is required 
    //(due to the types of NAT or firewall restrictions mentioned), not having
    // a valid TURN configuration means the connection attempt will fail.
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
          // 'url': 'stun:stun.l.google.com:19302',// Google's public STUN server, no credentials required
        },
        // {
        //   'url': 'turn:your.turn.servers.here',  // Replace with your actual TURN server
        //   'username': 'turn_username',            // Replace with TURN username
        //   'credential': 'turn_password'           // Replace with TURN password
        // }
      ]
    };
    //Old way: (streams, now we can ommit constraints)
    // Map<String, dynamic> constraints = {
    //   'mandatory': {
    //     'OfferToReceiveAudio': true,
    //     'OfferToReceiveVideo': true,
    //   },
    //   'optional': [],
    // };
    // Note: order of activities is important and has been corrected
    //       It's better to set up all event handlers before creating the RTCPeerConnection 
    //       and definitely before adding streams or initializing any part of the connection 
    //       that could trigger these events.
    // Initialize the peer connection
    // _peerConnection = await createPeerConnection(configuration, constraints);
    _peerConnection = await createPeerConnection(configuration); // CONNECTING HERE

    // Setup event handlers

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      // When an ICE candidate is found, add it to Firestore
      _sendIceCandidate(candidate);
    };
    // Understanding When Streams Are Added
    // Streams are added to the RTCPeerConnection in a couple of scenarios:
    // Locally: When you explicitly add a local stream using _peerConnection.addStream(_localStream); as in your setup. This is typically done right after acquiring the stream via getUserMedia.
    // Remotely: When the remote peer adds a stream to their connection, and it is transmitted over the WebRTC connection as part of the session. This triggers the onAddStream event on your local peer connection.    
    // _peerConnection.onAddStream = (MediaStream stream) {
    //   // Set the received stream to the remote renderer
    //   setState(() {
    //     _remoteRenderer.srcObject = stream;
    //   });
    // };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      // _peerConnection.addStream(_localStream); <- Old way
      // Add each track to the peer connection (in place of addStream[the old way])
      _localStream.getTracks().forEach((track) { // <- new way
        _peerConnection.addTrack(track, _localStream);
      });
      // Handle incoming tracks 
      _peerConnection.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      };
      // Firestore signaling logic would go here
      _listenForOffers();//if offer in FS handle it 
      _listenForAnswers();
      _listenForIceCandidates();
    } catch (e) {
      // Handle the error
      print("Error in setting up the local stream: $e");
    }
  }//end of setup web rtc
    // =========== setupwebrtc to here ===========
  void _sendOffer(RTCSessionDescription description) async {
    await _firestore
        .collection('videoRooms').doc(videoRoomId)
        .collection('participants').doc(userId)
        .set({
      'offer': {
        'sdp': description.sdp,
        'type': description.type,
      },
    }, SetOptions(merge: true));
  }
  void _listenForOffers() {
    _firestore
        .collection('videoRooms').doc(videoRoomId)
        .collection('participants')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.id != userId && doc.data().containsKey('offer')) {
          // Handle the received offer
          var offer = doc.data()['offer'];
          _handleReceivedOffer(offer, doc.id);
        }
      }
    });
  }
  void _handleReceivedOffer(Map<String, dynamic> offer, String senderId) async {
    // Assume you've received an offer from a remote peer, now create an answer
    // setRemote>createAnswer>setLocal>send(write)
    RTCSessionDescription description = RTCSessionDescription(offer['sdp'], offer['type']);
    await _peerConnection.setRemoteDescription(description);
    // RTCAnswerOptions answerOptions = RTCAnswerOptions(
    //   offerToReceiveAudio: true,
    //   offerToReceiveVideo: true
    // );
    RTCSessionDescription? answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);
    // Send the answer back to the peer who is listening to changes
    if (answer != null) {
      await _firestore
          .collection('videoRooms').doc(videoRoomId)
          .collection('participants').doc(senderId)
          .set({
            'answer': {
              'sdp': answer.sdp,
              'type': answer.type,
            },
          }, SetOptions(merge: true));
    }
  }

  void _listenForAnswers() {
    _firestore
        .collection('videoRooms')
        .doc(videoRoomId)
        .collection('participants')
        .doc(userId)
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.data()?.containsKey('answer') == true) {
        // Now it's safe to assume 'answer' exists in the data, Handle the received answer
        var answer = documentSnapshot.data()!['answer'];
        _handleReceivedAnswer(answer);
      }
    });
  }

  void _handleReceivedAnswer(Map<String, dynamic> answer) async {
    // Set the remote description with the answer from the remote peer
    RTCSessionDescription description =
        RTCSessionDescription(answer['sdp'], answer['type']);
    await _peerConnection.setRemoteDescription(description);
  }

  void _sendIceCandidate(RTCIceCandidate candidate) async {
    await _firestore
        .collection('videoRooms')
        .doc(videoRoomId)
        .collection('participants')
        .doc(userId)
        .collection('iceCandidates')
        .add({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  void _listenForIceCandidates() {
    _firestore
        .collection('videoRooms').doc(videoRoomId)
        .collection('participants')
        // Assuming you want to listen to a specific user's ICE candidates
        .doc('other_user_id') // Replace with the actual participant's user ID
        .collection('iceCandidates')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        // Add the received ICE candidates to the peer connection
        _addIceCandidate(doc.data());
      }
    });
  }

  void _addIceCandidate(Map<String, dynamic> candidateData) {
    RTCIceCandidate candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    _peerConnection.addCandidate(candidate);
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User?>(context);  // must be accessed in a lifecycle method like Build
    userId = _user.uid; //~'your_user_id'; // This should be the authenticated user's ID    return Scaffold(
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Video with WebRTC'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add action for settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Add action for refresh
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_localRenderer, mirror: true),
          ),
          const Center(
            child: Text('WebRTC setup in progress...'),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
        ],
      ),
    );
  }

  // Private helper methods such as _initializeVideoRenderer and _setupWebRTC should be added here
}
