From: David Miller <davem@davemloft.net>
Subject: [PATCH] MAINTAINERS: Add "B:" field for networking.
Date: Fri, 21 Apr 2017 10:45:30 -0400 (EDT)
Message-ID: <20170421.104530.783586906821012854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041719AbdDUSWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:22:31 -0400
Received: from localhost (unknown [38.140.131.194])
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id A5875121303EA
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 07:04:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We want people to report bugs to the netdev list.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 63f8abc..08950e5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8761,6 +8761,7 @@ W:	http://www.linuxfoundation.org/en/Net
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
+B:	mailto:netdev@vger.kernel.org
 S:	Maintained
 F:	net/
 F:	include/net/
-- 
2.4.11
