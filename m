From: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v3 8/9] MAINTAINERS: Add entry for Altera Triple Speed Ethernet Driver
Date: Tue, 11 Mar 2014 17:43:10 -0500
Message-ID: <1394577791-6547-9-git-send-email-vbridgers2013@gmail.com>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org, vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394577791-6547-1-git-send-email-vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a MAINTAINERS entry covering the Altera Triple Speed
Ethernet Driver, with support for the MSGDMA and SGDMA
soft DMA IP components.

Signed-off-by: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
V3: - Reorder commits, otherwise no change to these files from V2

V2: - Add a patch to update MAINTAINERS file, it was missed on the
      initial RFC submission.
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e4ee191..cfa0dfa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -536,6 +536,13 @@ S:	Odd Fixes
 L:	linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 F:	arch/alpha/
 
+ALTERA TRIPLE SPEED ETHERNET DRIVER
+M:	Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
+L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+L:	nios2-dev-g9ZBwUv/Ih/yUk5EbOjzuce+I+R0W71w@public.gmane.org (moderated for non-subscribers)
+S:	Maintained
+F:	drivers/net/ethernet/altera/
+
 ALTERA UART/JTAG UART SERIAL DRIVERS
 M:	Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
 L:	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
