From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] ixgbevf.txt: Update ixgbevf documentation
Date: Tue, 05 Oct 2010 04:16:44 -0700
Message-ID: <20101005111643.23000.38976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:36939
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758137Ab0JELRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 07:17:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the documentation for the ixgbevf (ixgbe virtual
function driver).

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/ixgbevf.txt |   40 +++-------------------------------
 1 files changed, 3 insertions(+), 37 deletions(-)
 mode change 100755 => 100644 Documentation/networking/ixgbevf.txt

diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/ixgbevf.txt
old mode 100755
new mode 100644
index 19015de..21dd5d1
--- a/Documentation/networking/ixgbevf.txt
+++ b/Documentation/networking/ixgbevf.txt
@@ -1,19 +1,16 @@
 Linux* Base Driver for Intel(R) Network Connection
 ==================================================
 
-November 24, 2009
+Intel Gigabit Linux driver.
+Copyright(c) 1999 - 2010 Intel Corporation.
 
 Contents
 ========
 
-- In This Release
 - Identifying Your Adapter
 - Known Issues/Troubleshooting
 - Support
 
-In This Release
-===============
-
 This file describes the ixgbevf Linux* Base Driver for Intel Network
 Connection.
 
@@ -33,7 +30,7 @@ Identifying Your Adapter
 For more information on how to identify your adapter, go to the Adapter &
 Driver ID Guide at:
 
-    http://support.intel.com/support/network/sb/CS-008441.htm
+    http://support.intel.com/support/go/network/adapter/idguide.htm
 
 Known Issues/Troubleshooting
 ============================
@@ -57,34 +54,3 @@ or the Intel Wired Networking project hosted by Sourceforge at:
 If an issue is identified with the released source code on the supported
 kernel with a supported adapter, email the specific information related
 to the issue to e1000-devel@lists.sf.net
-
-License
-=======
-
-Intel 10 Gigabit Linux driver.
-Copyright(c) 1999 - 2009 Intel Corporation.
-
-This program is free software; you can redistribute it and/or modify it
-under the terms and conditions of the GNU General Public License,
-version 2, as published by the Free Software Foundation.
-
-This program is distributed in the hope it will be useful, but WITHOUT
-ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-more details.
-
-You should have received a copy of the GNU General Public License along with
-this program; if not, write to the Free Software Foundation, Inc.,
-51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-The full GNU General Public License is included in this distribution in
-the file called "COPYING".
-
-Trademarks
-==========
-
-Intel, Itanium, and Pentium are trademarks or registered trademarks of
-Intel Corporation or its subsidiaries in the United States and other
-countries.
-
-* Other names and brands may be claimed as the property of others.

