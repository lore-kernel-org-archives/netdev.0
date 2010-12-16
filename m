From: Petr Sabata <psabata@redhat.com>
Subject: [PATCH] ip: Few typo and grammar errors fixes for ip(8) manpage
Date: Thu, 16 Dec 2010 17:24:54 +0100
Message-ID: <1292516694-9156-1-git-send-email-psabata@redhat.com>
Cc: Petr Sabata <psabata@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab0LPQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 11:25:00 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oBGGOxZH005347
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 11:25:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ip.8 |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 6c778d2..8d55fa9 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -1289,7 +1289,7 @@ can also be
 .BI nud " NUD_STATE"
 the state of the neighbour entry.
 .B nud
-is an abbreviation for 'Neigh bour Unreachability Detection'.
+is an abbreviation for 'Neighbour Unreachability Detection'.
 The state can take one of the following values:
 
 .in +8
@@ -1614,7 +1614,7 @@ peers are allowed to send to us.
 .BI rtt " TIME"
 the initial RTT ('Round Trip Time') estimate. If no suffix is
 specified the units are raw values passed directly to the
-routing code to maintain compatability with previous releases.
+routing code to maintain compatibility with previous releases.
 Otherwise if a suffix of s, sec or secs is used to specify
 seconds; ms, msec or msecs to specify milliseconds; us, usec
 or usecs to specify microseconds; ns, nsec or nsecs to specify
@@ -2484,7 +2484,7 @@ contains one or more algorithms
 .I ALGO
 which depend on the type of algorithm set by
 .IR ALGO_TYPE "."
-It can be used these algoritms
+Valid algorithms are:
 .BR enc ", " auth " or " comp "."
 
 .SS ip xfrm policy add - add a new policy
-- 
1.7.3.3

