From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] MAINTAINERS: add networking selftests to NETWORKING
Date: Thu, 13 Mar 2014 10:18:53 +0100
Message-ID: <1394702333-32578-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbaCMJS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 05:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add it to NETWORKING [GENERAL] to make sure patches for selftests
go to the netdev list as well.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e1be77c..b359eb0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6003,6 +6003,7 @@ F:	include/uapi/linux/in.h
 F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
 F:	tools/net/
+F:	tools/testing/selftests/net/
 
 NETWORKING [IPv4/IPv6]
 M:	"David S. Miller" <davem@davemloft.net>
-- 
1.7.11.7
