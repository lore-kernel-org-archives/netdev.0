From: "Pranav" <pranav@nodeinfotech.com>
Subject: Problem in IKE implemenation in linux(RACE CONDITION)
Date: Thu, 29 Jul 2004 15:08:08 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BLEAIJDEHOOAGALIAAKBIEJNCAAA.pranav@nodeinfotech.com>
Reply-To: <pranav@nodeinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev-bounce@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi everyone,
             I am working on IKE implementaion on linux.
i have got a problem in negoatiation when both the peers start negotiating
at the same time,
both peers acting as initiator causing race condition.

Race condition happens only when both the peer's start the same
application(like ping or telnet)with eachother at the same time.

can anybody help me out of this problem..

With Regards,
Pranav Jadhav
