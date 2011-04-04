From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] MAINTAINERS: add entry for Xen network backend
Date: Mon,  4 Apr 2011 09:26:07 +0100
Message-ID: <1301905567-7880-1-git-send-email-ian.campbell@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xensource.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 MAINTAINERS |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6b4b9cd..bb702f3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6916,6 +6916,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mjg59/platform-drivers-x86.
 S:	Maintained
 F:	drivers/platform/x86
 
+XEN NETWORK BACKEND DRIVER
+M:	Ian Campbell <ian.campbell@citrix.com>
+L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
+S:	Supported
+F:	drivers/net/xen-netback/*
+
 XEN PCI SUBSYSTEM
 M:	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
 L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
-- 
1.7.2.5
