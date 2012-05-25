From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH iproute2] tc-codel: Fix typos in manpage
Date: Fri, 25 May 2012 09:43:04 +0200
Message-ID: <1337931784-8625-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jan Ceuleers <jan.ceuleers@computer.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:9732 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362Ab2EYHns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 03:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 man/man8/tc-codel.8 |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-codel.8 b/man/man8/tc-codel.8
index 605e498..61f163f 100644
--- a/man/man8/tc-codel.8
+++ b/man/man8/tc-codel.8
@@ -105,7 +105,7 @@ interval 30.0ms ecn
 .BR tc-red (8)
 
 .SH SOURCES
-o   Kathleen Nicols and Van Jaconson, "Controlling Queue Delay", ACM Queue,
+o   Kathleen Nichols and Van Jacobson, "Controlling Queue Delay", ACM Queue,
 http://queue.acm.org/detail.cfm?id=2209336
 
 .SH AUTHORS
-- 
1.7.9.5
