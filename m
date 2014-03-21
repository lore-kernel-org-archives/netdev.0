From: Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V10 7/7] MAINTAINERS: add maintainer for Samsung sxgbe driver
Date: Fri, 21 Mar 2014 11:06:55 -0700
Message-ID: <005d01cf4530$590cedc0$0b26c940$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	'GIRISH K S' <ks.giri-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'SIVAREDDY KALLAM' <siva.kallam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'Vipul Chandrakant' <vipul.pandya-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	'Ilho Lee' <ilho215.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-language: en-us
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
---
 MAINTAINERS |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index b7befe7..aeb81f2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7536,6 +7536,15 @@ S:	Supported
 L:	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (moderated for non-subscribers)
 F:	drivers/clk/samsung/
 
+SAMSUNG SXGBE DRIVERS
+M:	Byungho An <bh74.an-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
+M:	Girish K S <ks.giri-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
+M:	Siva Reddy Kallam <siva.kallam-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
+M:	Vipul Pandya <vipul.pandya-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
+S:	Supported
+L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+F:	drivers/net/ethernet/samsung/sxgbe/
+
 SERIAL DRIVERS
 M:	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
 L:	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-- 
1.7.10.4


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
