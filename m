From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [Ntop-misc] Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond	Device
 Polling
Date: Wed, 7 Apr 2004 17:11:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16500.6683.524806.636701@robur.slu.se>
References: <20040330142354.GA17671@outblaze.com>
	<1081033332.2037.61.camel@jzny.localdomain>
	<c4rvvv$dbf$1@sea.gmane.org>
	<1081261126.1047.6.camel@jzny.localdomain>
	<16498.52551.712261.214192@robur.slu.se>
	<4073A7AF.5060401@ntop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ntop-misc@fuji.unipi.it
In-Reply-To: <4073A7AF.5060401@ntop.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Luca Deri writes:

 > Robert,
 > yes I run into this problems and I have solved using the RTIRQ kernel patch.

 Hello!

 I found a reference in your mail... After a very quick look I don't see how RTIRQ 
 can solve any of softirq/userland balance problems. It's seems to deal with
 getting realtime-like interrupt responsiveness during load.

 Cheers.
							--ro
