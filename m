From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 29/29] wimax/i2400m: add CREDITS and MAINTAINERS entries
Date: Mon, 15 Dec 2008 04:58:24 -0800
Message-ID: <1aab89527c855aff3ba7b4bbb29c55312074ad48.1229345780.git.inaky@linux.intel.com>
References: <cover.1229345769.git.inaky@linux.intel.com>
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1229345769.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

This patch adds entries for the original developers of the i2400m
drivers and up-to-date maintainer entries.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 CREDITS     |   17 +++++++++++++++++
 MAINTAINERS |   16 ++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/CREDITS b/CREDITS
index b50db17..ae5b804 100644
--- a/CREDITS
+++ b/CREDITS
@@ -464,6 +464,11 @@ S: 1200 Goldenrod Dr.
 S: Nampa, Idaho 83686
 S: USA
 
+N: Dirk J. Brandewie
+E: dirk.j.brandewie@intel.com
+E: linux-wimax@intel.com
+D: Intel Wireless WiMAX Connection 2400 SDIO driver
+
 N: Derrick J. Brashear
 E: shadow@dementia.org
 W: http://www.dementia.org/~shadow
@@ -2119,6 +2124,11 @@ N: H.J. Lu
 E: hjl@gnu.ai.mit.edu
 D: GCC + libraries hacker
 
+N: Yanir Lubetkin
+E: yanirx.lubatkin@intel.com
+E: linux-wimax@intel.com
+D: Intel Wireless WiMAX Connection 2400 driver
+
 N: Michal Ludvig
 E: michal@logix.cz
 E: michal.ludvig@asterisk.co.nz
@@ -2693,6 +2703,13 @@ S: RR #5, 497 Pole Line Road
 S: Thunder Bay, Ontario
 S: CANADA P7C 5M9
 
+N: Inaky Perez-Gonzalez
+E: inaky.perez-gonzalez@intel.com
+E: linux-wimax@intel.com
+E: inakypg@yahoo.com
+D: WiMAX stack
+D: Intel Wireless WiMAX Connection 2400 driver
+
 N: Yuri Per
 E: yuri@pts.mipt.ru
 D: Some smbfs fixes
diff --git a/MAINTAINERS b/MAINTAINERS
index c1ea1f6..892b57a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2299,6 +2299,14 @@ W:	http://lists.sourceforge.net/mailman/listinfo/ipw2100-devel
 W:	http://ipw2200.sourceforge.net
 S:	Supported
 
+INTEL WIRELESS WIMAX CONNECTION 2400
+P:	Inaky Perez-Gonzalez
+M:	inaky.perez-gonzalez@intel.com
+M:	linux-wimax@intel.com
+L:	wimax@linuxwimax.org
+S:	Supported
+W:	http://linuxwimax.org
+
 INTEL WIRELESS WIFI LINK (iwlwifi)
 P:	Zhu Yi
 M:	yi.zhu@intel.com
@@ -4703,6 +4711,14 @@ M:	zaga@fly.cc.fer.hr
 L:	linux-scsi@vger.kernel.org
 S:	Maintained
 
+WIMAX STACK
+P:	Inaky Perez-Gonzalez
+M:	inaky.perez-gonzalez@intel.com
+M:	linux-wimax@intel.com
+L:	wimax@linuxwimax.org
+S:	Supported
+W:	http://linuxwimax.org
+
 WIMEDIA LLC PROTOCOL (WLP) SUBSYSTEM
 P:	David Vrabel
 M:	david.vrabel@csr.com
-- 
1.5.6.5
