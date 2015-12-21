From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V1 15/16] i40iw: add entry in rdma_netlink
Date: Mon, 21 Dec 2015 17:13:15 -0600
Message-ID: <1450739596-23276-16-git-send-email-faisal.latif@intel.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-10-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-11-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-12-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-13-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-14-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-15-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-15-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add entry for port mapper services.

Signed-off-by: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/uapi/rdma/rdma_netlink.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index c19a5dc..4fa418d 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -8,6 +8,7 @@ enum {
 	RDMA_NL_NES,
 	RDMA_NL_C4IW,
 	RDMA_NL_LS,	/* RDMA Local Services */
+	RDMA_NL_I40IW,
 	RDMA_NL_NUM_CLIENTS
 };
 
-- 
2.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
