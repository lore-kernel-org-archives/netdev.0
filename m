From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net-next] vrf: duplicate include of rtnetlink.h
Date: Tue, 9 Feb 2016 22:11:27 -0800
Message-ID: <20160209221127.6e1b7769@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <shm@cumulusnetworks.com>,
	"David Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:45847 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757048AbcBJGLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 01:11:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vrf.c	2015-12-10 08:57:12.573235836 -0800
+++ b/drivers/net/vrf.c	2015-12-14 19:08:59.672199087 -0800
@@ -32,7 +32,6 @@
 #include <net/ip_fib.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
-#include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
