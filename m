From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] MAINTAINERS: transfer maintainership of I/OAT
Date: Thu, 14 Jan 2010 16:52:42 +0100
Message-ID: <20100114155217.11352.15918.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756911Ab0ANPxo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams takes over I/OAT from Maciej Sosnowski

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 MAINTAINERS |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c8f47bf..8d13c98 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -988,7 +988,6 @@ F:	drivers/platform/x86/asus-laptop.c
 
 ASYNCHRONOUS TRANSFERS/TRANSFORMS (IOAT) API
 M:	Dan Williams <dan.j.williams@intel.com>
-M:	Maciej Sosnowski <maciej.sosnowski@intel.com>
 W:	http://sourceforge.net/projects/xscaleiop
 S:	Supported
 F:	Documentation/crypto/async-tx-api.txt
@@ -1825,7 +1824,6 @@ S:	Supported
 F:	fs/dlm/
 
 DMA GENERIC OFFLOAD ENGINE SUBSYSTEM
-M:	Maciej Sosnowski <maciej.sosnowski@intel.com>
 M:	Dan Williams <dan.j.williams@intel.com>
 S:	Supported
 F:	drivers/dma/
@@ -2788,7 +2786,7 @@ F:	arch/x86/kernel/microcode_core.c
 F:	arch/x86/kernel/microcode_intel.c
 
 INTEL I/OAT DMA DRIVER
-M:	Maciej Sosnowski <maciej.sosnowski@intel.com>
+M:	Dan Williams <dan.j.williams@intel.com>
 S:	Supported
 F:	drivers/dma/ioat*
 
