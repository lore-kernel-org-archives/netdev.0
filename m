From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 6/7] I/OAT: Add entries to MAINTAINERS for the DMA memcpy subsystem and ioatdma
Date: Wed, 18 Oct 2006 16:46:59 -0700
Message-ID: <20061018234659.26671.29694.stgit@gitlost.site>
References: <20061018234417.26671.56773.stgit@gitlost.site>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53262 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1423168AbWJRXjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 19:39:03 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jeff@garzik.org
In-Reply-To: <20061018234417.26671.56773.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 MAINTAINERS |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5305dd6..533adbe 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -915,6 +915,12 @@ M:	tori@unhappy.mine.nu
 L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
+DMA GENERIC MEMCPY SUBSYSTEM
+P:	Chris Leech
+M:	christopher.leech@intel.com
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+
 DOCBOOK FOR DOCUMENTATION
 P:	Martin Waitz
 M:	tali@admingilde.org
@@ -1516,6 +1522,12 @@ P:	Tigran Aivazian
 M:	tigran@veritas.com
 S:	Maintained
 
+INTEL I/OAT DMA DRIVER
+P:	Chris Leech
+M:	christopher.leech@intel.com
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+
 INTEL IXP4XX RANDOM NUMBER GENERATOR SUPPORT
 P:	Deepak Saxena
 M:	dsaxena@plexity.net

