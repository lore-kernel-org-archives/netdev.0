From: Dave Jones <davej@redhat.com>
Subject: Re: 2.6.17-rc6-mm1
Date: Wed, 7 Jun 2006 14:21:06 -0400
Message-ID: <20060607182106.GO10465@redhat.com>
References: <20060607104724.c5d3d730.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41166 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751210AbWFGSVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 14:21:13 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060607104724.c5d3d730.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 10:47:24AM -0700, Andrew Morton wrote:

 > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc6/2.6.17-rc6-mm1/

Just spotted this typo in a new option.

Signed-off-by: Dave Jones <davej@redhat.com>

--- rc6mm1/net/Kconfig~	2006-06-07 14:19:44.000000000 -0400
+++ rc6mm1/net/Kconfig	2006-06-07 14:19:58.000000000 -0400
@@ -227,7 +227,7 @@ config NET_TCPPROBE
 	depends on INET && EXPERIMENTAL && PROC_FS && KPROBES
 	---help---
 	This module allows for capturing the changes to TCP connection
-	state in response to incoming patckets. It is used for debugging
+	state in response to incoming packets. It is used for debugging
 	TCP congestion avoidance modules. If you don't understand
 	what was just said, you don't need it: say N.
 


-- 
http://www.codemonkey.org.uk
