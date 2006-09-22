From: Grant Grundler <grundler@parisc-linux.org>
Subject: PATCH: fix cut/paste error in TCPPROBE
Date: Fri, 22 Sep 2006 08:47:10 -0600
Message-ID: <20060922144710.GB26719@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:31902 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S932550AbWIVOrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 10:47:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by colo.lackof.org (Postfix) with ESMTP id 8B21836003C
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 08:47:12 -0600 (MDT)
Received: from colo.lackof.org ([127.0.0.1])
	by localhost (colo.lackof.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 28362-03 for <netdev@vger.kernel.org>;
	Fri, 22 Sep 2006 08:47:10 -0600 (MDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix cut/paste error in TCPPROBE help text.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>


--- a/net/Kconfig
+++ b/net/Kconfig
@@ -231,7 +231,7 @@ config NET_TCPPROBE
 	TCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 
-	Documentation on how to use the packet generator can be found
+	Documentation on how to use TCP connection probing can be found
 	at http://linux-net.osdl.org/index.php/TcpProbe
 
 	To compile this code as a module, choose M here: the
