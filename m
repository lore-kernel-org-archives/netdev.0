From: "J. M." <snortwiz@hotmail.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on a Li
Date: Thu, 13 May 2004 12:45:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY15-F10TbdkSmLAzt00054421@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: niv@us.ibm.com, dlstevens@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>On Linux, IP addresses are not bound to interfaces.  You need
>to use SO_BINDTODEVICE if that is what you want.

IP's are not bound to a specific interface - makes sense to me why the 
traffic acts the way it acts.

>The security model is correct, and well defined, just different than BSD
>derived systems.  It does conform to the standards (RFC's).

The model is logical, may be well defined, and could conform to every 
applicable RFC - but I would argue that it's got its problems.  After all, 
conforming to RFC's doesn't make something secure and flawless - just look 
at security flaws in TCP/IP designs over the years that followed the RFC's.  
:)

_________________________________________________________________
Watch LIVE baseball games on your computer with MLB.TV, included with MSN 
Premium! 
http://join.msn.com/?page=features/mlb&pgmarket=en-us/go/onm00200439ave/direct/01/
