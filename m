From: "Bloch, Jack" <Jack.Bloch@icn.siemens.com>
Subject: IP stack question
Date: Mon, 24 Jun 2002 07:39:55 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <180577A42806D61189D30008C7E632E8793946@boca213a.boca.ssc.siemens.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <owner-netdev@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

I am writing this e-mail at the recommendation of Alan Cox. I have an
embedded system running on cPCI HW which has two physical Ethernet
connections. This system is connected to an internal network and the IP
addresses are not made public. I use the IP addresses 10.1.1.4 and 10.1.1.5
respectively. The two physical ports are connected to two separate LAN
switches which are connected by an uplink. I want to periodically test this
uplink cable. My plan to do this is to send a simple test message (much like
a ping) from 10.1.1.4 to 10.1.1.5, however, the IP stack does not let me do
this. Is there any specific reason why not?

Jack Bloch
Siemens Carrier Networks
e-mail    : jack.bloch@icn.siemens.com
phone     : (561) 923-6550
