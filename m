From: "Sameer" <sameer@dlink.co.in>
Subject: linux icmp: Why socket and inode are allocated?
Date: Mon, 29 Mar 2004 10:07:46 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005c01c41547$97ca85f0$9064a8c0@sameer>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,
I am currently studying linux ICMP implementation
In that i find there a socket and inode data structures being initialized=
..
later in the icmp_init function it is said that we do not wish this socke=
t
to see the incoming packets..
So why a socket and an inode structures are used for icmp?

Thanks and Regards,

$@M=A3=A3R!
Sameer Kelkar.
D-Link (India) Ltd.
Bangalore
India.
