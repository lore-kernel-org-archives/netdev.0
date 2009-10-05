From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] add maintainer for network drop monitor kernel service
Date: Mon, 5 Oct 2009 09:56:55 -0400
Message-ID: <20091005135653.GB2898@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56715 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbZJEN5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 09:57:43 -0400
Received: from nat-pool-rdu.redhat.com ([66.187.233.202] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1Muo3j-0000Xa-Mr
	for netdev@vger.kernel.org; Mon, 05 Oct 2009 09:57:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was getting ribbed about this earlier, so I figured I'd make it official.  Add
myself as the maintainer of the drop monitor bits, so people don't just gripe at
Dave when it breaks (I'm sure it will never break, but just in case :) ).

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 09a2028..c57c2e6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3643,6 +3643,13 @@ F:	Documentation/blockdev/nbd.txt
 F:	drivers/block/nbd.c
 F:	include/linux/nbd.h
 
+NETWORK DROP MONITOR
+M:	Neil Horman <nhorman@tuxdriver.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+W:	https://fedorahosted.org/dropwatch/
+F:	net/core/drop_monitor.c
+
 NETWORKING [GENERAL]
 M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
