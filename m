From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] sctp: fix missing SCTP mailing list address update
Date: Sun, 19 Jan 2014 15:24:53 -0700
Message-ID: <1390170293-15851-1-git-send-email-sakiwit@gmail.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49760 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbaASW2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 17:28:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 91705c61b5202 ("net: sctp: trivial: update mailing list
address") updated almost all the SCTP mailing list address from

	"lksctp-developers@lists.sourceforge.net"
to
	"linux-sctp@vger.kernel.org"

except for the one in include/linux/sctp.h file. Fix this way trivial
one so that all is updated.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/sctp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index c4c5eba26d9f..a9414fd49dc6 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developerst@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
