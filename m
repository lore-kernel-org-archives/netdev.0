From: Leonard Norrgard <leonard.norrgard@refactor.fi>
Subject: [PATCH] MAINTAINERS, use the correct "Orphan" rather than "Orphaned"
Date: Wed, 10 Jan 2007 23:20:20 +0200
Message-ID: <45A55894.3050205@refactor.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010909050405050003050805"
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965108AbXAJVU0@vger.kernel.org>
To: Eng.Linux@digi.com, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010909050405050003050805
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Simplify automatic parsing of MAINTAINERS, by using the correct "Orphan"
rather than "Orphaned".

Signed-off-by: Leonard Norrgård <leonard.norrgard@refactor.fi>



--------------010909050405050003050805
Content-Type: text/x-patch;
 name="maintainers-format.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="maintainers-format.patch"

diff --git a/MAINTAINERS b/MAINTAINERS
index 4ccc5fa..7595bc8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1031,13 +1031,13 @@ P:	Digi International, Inc
 M:	Eng.Linux@digi.com
 L:	Eng.Linux@digi.com
 W:	http://www.digi.com
-S:	Orphaned
+S:	Orphan
 
 DIGI RIGHTSWITCH NETWORK DRIVER
 P:	Rick Richardson
 L:	netdev@vger.kernel.org
 W:	http://www.digi.com
-S:	Orphaned
+S:	Orphan
 
 DIRECTORY NOTIFICATION
 P:	Stephen Rothwell

--------------010909050405050003050805--
