From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 12/12] Drop bogus reference to tc-filters and add lartc.org link to manpage.
Date: Fri, 12 Oct 2007 10:56:47 +0200
Message-ID: <1192179407-22461-12-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
 <1192179407-22461-6-git-send-email-andreas@fatal.se>
 <1192179407-22461-7-git-send-email-andreas@fatal.se>
 <1192179407-22461-8-git-send-email-andreas@fatal.se>
 <1192179407-22461-9-git-send-email-andreas@fatal.se>
 <1192179407-22461-10-git-send-email-andreas@fatal.se>
 <1192179407-22461-11-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:55355 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbXJLJHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 05:07:16 -0400
In-Reply-To: <1192179407-22461-11-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Wirt <formorer@debian.org>


Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 man/man8/ip.8 |    2 ++
 man/man8/tc.8 |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 153123a..8fd6d52 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -1830,6 +1830,8 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .RB "IP Command reference " ip-cref.ps
 .br
 .RB "IP tunnels " ip-cref.ps
+.br
+.RB "User documentation at " http://lartc.org/ ", but please direct bugreports and patches to: " <netdev@vger.kernel.org>
 
 .SH AUTHOR
 Original Manpage  by Michail Litvak <mci@owl.openwall.com>
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 6acd572..53a866f 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -339,7 +339,8 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-pfifo (8),
 .BR tc-bfifo (8),
 .BR tc-pfifo_fast (8),
-.BR tc-filters (8)
+.br
+.RB "User documentation at " http://lartc.org/ ", but please direct bugreports and patches to: " <netdev@vger.kernel.org>
 
 .SH AUTHOR
 Manpage maintained by bert hubert (ahu@ds9a.nl)
-- 
1.5.3.4

