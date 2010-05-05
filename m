From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH/RFC] cxgb4: Add MAINTAINERS info
Date: Wed, 05 May 2010 12:01:37 -0700
Message-ID: <adawrvijhpq.fsf_-_@roland-alpha.cisco.com>
References: <20100428164341.cee2911a.sfr@canb.auug.org.au>
	<20100428103356.931ba48c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100428103356.931ba48c.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> (Randy Dunlap's
	message of "Wed, 28 Apr 2010 10:33:56 -0700")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi guys, does this info for cxgb4/iw_cxgb4 (pretty much copied from
cxgb3, except with Dimitris instead of Divy) look right?  If so I'll add
it to my tree.

Thanks,
  Roland
---
diff --git a/MAINTAINERS b/MAINTAINERS
index 7a9ccda..a00231b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1719,6 +1719,20 @@ W:	http://www.openfabrics.org
 S:	Supported
 F:	drivers/infiniband/hw/cxgb3/
 
+CXGB4 ETHERNET DRIVER (CXGB4)
+M:	Dimitris Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
+L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+W:	http://www.chelsio.com
+S:	Supported
+F:	drivers/net/cxgb4/
+
+CXGB4 IWARP RNIC DRIVER (IW_CXGB4)
+M:	Steve Wise <swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
+L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+W:	http://www.openfabrics.org
+S:	Supported
+F:	drivers/infiniband/hw/cxgb4/
+
 CYBERPRO FB DRIVER
 M:	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
 L:	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org (moderated for non-subscribers)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
