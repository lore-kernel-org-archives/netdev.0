From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH iproute2] Add reference to tc-codel(8) to the SEE ALSO section
Date: Sat,  2 Jun 2012 21:45:10 +0200
Message-ID: <1338666310-18744-1-git-send-email-jan.ceuleers@computer.org>
Cc: andyqos@ukfsn.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:47288 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965720Ab2FBTpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 15:45:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Andy Furniss <andyqos@ukfsn.org>
Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 man/man8/tc.8 |    1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 6576377..14a1cd8 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -368,6 +368,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .SH SEE ALSO
 .BR tc-cbq (8),
 .BR tc-choke (8),
+.BR tc-codel (8),
 .BR tc-drr (8),
 .BR tc-htb (8),
 .BR tc-hfsc (8),
-- 
1.7.9.5
