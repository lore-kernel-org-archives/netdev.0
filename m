From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-link: fix minor typo in manpage
Date: Tue, 11 Aug 2015 19:14:11 +0200
Message-ID: <1439313251-9043-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53539 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965269AbbHKRON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 13:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change '-human-readble' to '-human-readable'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index c123fcc..1c312af 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -889,7 +889,7 @@ output more statistics about packet usage.
 output more detailed information.
 
 .TP
-.BR "\-h", " \-human", " \-human-readble"
+.BR "\-h", " \-human", " \-human-readable"
 output statistics with human readable values number followed by suffix
 
 .TP
-- 
2.1.2
