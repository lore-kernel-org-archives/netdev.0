From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: trivial: add uapi/linux/sctp.h into maintainers
Date: Tue, 23 Jul 2013 14:51:48 +0200
Message-ID: <1374583908-17152-2-git-send-email-dborkman@redhat.com>
References: <1374583908-17152-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932168Ab3GWMvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 08:51:53 -0400
In-Reply-To: <1374583908-17152-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this file has moved to the uapi section, we also need to update
this in the maintainers file.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index bf61e04..339e798 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7216,6 +7216,7 @@ W:	http://lksctp.sourceforge.net
 S:	Maintained
 F:	Documentation/networking/sctp.txt
 F:	include/linux/sctp.h
+F:	include/uapi/linux/sctp.h
 F:	include/net/sctp/
 F:	net/sctp/
 
-- 
1.7.11.7
