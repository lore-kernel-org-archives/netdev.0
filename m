From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] bonding: update MAINTAINERS
Date: Tue,  1 Oct 2013 21:23:25 -0400
Message-ID: <1380677005-23745-1-git-send-email-andy@greyhouse.net>
Cc: vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881Ab3JBBXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 21:23:30 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r921NTVi012296
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 1 Oct 2013 21:23:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@redhat.com>

Veaceslav has been doing a significant amount of work on bonding lately and
reached out to me about being a maintainer.  After discussing this with him, I
think he would be a good fit as a bonding maintainer.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Veaceslav Falico <vfalico@redhat.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index b6b29c3..859e74a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1789,6 +1789,7 @@ F:	include/net/bluetooth/
 
 BONDING DRIVER
 M:	Jay Vosburgh <fubar@us.ibm.com>
+M:	Veaceslav Falico <vfalico@redhat.com>
 M:	Andy Gospodarek <andy@greyhouse.net>
 L:	netdev@vger.kernel.org
 W:	http://sourceforge.net/projects/bonding/
-- 
1.8.1.4
