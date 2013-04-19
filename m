From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Add .gitignore to networking selftests directory.
Date: Fri, 19 Apr 2013 16:36:30 -0400 (EDT)
Message-ID: <20130419.163630.1326166655377956879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab3DSUgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:36:33 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6FC7E581285
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 13:36:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/net/.gitignore | 3 +++
 1 file changed, 3 insertions(+)
 create mode 100644 tools/testing/selftests/net/.gitignore

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
new file mode 100644
index 0000000..0032662
--- /dev/null
+++ b/tools/testing/selftests/net/.gitignore
@@ -0,0 +1,3 @@
+socket
+psock_fanout
+psock_tpacket
-- 
1.7.11.7
