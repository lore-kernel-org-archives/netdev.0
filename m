From: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 0/1] Fix for module license in Broadcom Phy Library
Date: Thu, 15 Oct 2015 10:37:12 -0700
Message-ID: <1444930633-23314-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi
This patchset adds the module description, license & author to the
Broadcom Phy Library (drivers/net/phy/bcm-phy-lib.c) introduced by
the commit: a1cba5613edf5 ("net: phy: Add Broadcom phy library for
common interfaces")

Changes from v1:
-Created the patch based on David Miller's 'net-next' Kernel tree

Arun Parameswaran (1):
  net: phy: bcm-phy-lib: Fix module license issue

 drivers/net/phy/bcm-phy-lib.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
2.6.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
