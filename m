From: Reese Moore <ram@vt.edu>
Subject: [PATCH iproute2] iproute2: ip-link.8.in: Spelling fixes
Date: Wed,  4 Feb 2015 14:04:48 -0500
Message-ID: <1423076688-15563-1-git-send-email-ram@vt.edu>
Cc: Reese Moore <ram@vt.edu>, Stephen Hemminger <shemminger@osdl.org>,
	Dmitry Kozlov <xeb@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr1.cc.vt.edu ([198.82.141.52]:55554 "EHLO omr1.cc.vt.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbbBDTFD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 14:05:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ip-link(8) man page, for the gretap, ip6gre, and ip6gretap types, the
word tunnel was incorrectly spelled 'tuunel'.

Signed-off-by: Reese Moore <ram@vt.edu>
---
 man/man8/ip-link.8.in | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 1209b55..313d6f2 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -221,13 +221,13 @@ Link types:
 - Virtual tunnel interface GRE over IPv4
 .sp
 .BR gretap
-- Virtual L2 tuunel interface GRE over IPv4
+- Virtual L2 tunnel interface GRE over IPv4
 .sp
 .BR ip6gre
-- Virtual tuunel interface GRE over IPv6
+- Virtual tunnel interface GRE over IPv6
 .sp
 .BR ip6gretap
-- Virtual L2 tuunel interface GRE over IPv6
+- Virtual L2 tunnel interface GRE over IPv6
 .in -8
 
 .TP
-- 
2.2.2
