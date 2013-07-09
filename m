From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] Documentation: Fix references to defunct linux-net@vger.kernel.org
Date: Tue,  9 Jul 2013 10:22:31 +0200
Message-ID: <1373358151-26161-1-git-send-email-geert@linux-m68k.org>
Cc: linux-doc@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux-net@vger.kernel.org was replaced by netdev@oss.sgi.com was replaced
by netdev@vger.kernel.org.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 Documentation/networking/arcnet.txt |    7 ++++---
 Documentation/networking/vortex.txt |    2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/arcnet.txt b/Documentation/networking/arcnet.txt
index 9ff5795..aff97f4 100644
--- a/Documentation/networking/arcnet.txt
+++ b/Documentation/networking/arcnet.txt
@@ -70,9 +70,10 @@ list, mail to linux-arcnet@tichy.ch.uj.edu.pl.
 There are archives of the mailing list at:
 	http://epistolary.org/mailman/listinfo.cgi/arcnet
 
-The people on linux-net@vger.kernel.org have also been known to be very
-helpful, especially when we're talking about ALPHA Linux kernels that may or
-may not work right in the first place.
+The people on linux-net@vger.kernel.org (now defunct, replaced by
+netdev@vger.kernel.org) have also been known to be very helpful, especially
+when we're talking about ALPHA Linux kernels that may or may not work right
+in the first place.
 
 
 Other Drivers and Info
diff --git a/Documentation/networking/vortex.txt b/Documentation/networking/vortex.txt
index b4038ff..9a8041d 100644
--- a/Documentation/networking/vortex.txt
+++ b/Documentation/networking/vortex.txt
@@ -359,7 +359,7 @@ steps you should take:
 - OK, it's a driver problem.
 
    You need to generate a report.  Typically this is an email to the
-   maintainer and/or linux-net@vger.kernel.org.  The maintainer's
+   maintainer and/or netdev@vger.kernel.org.  The maintainer's
    email address will be in the driver source or in the MAINTAINERS file.
 
 - The contents of your report will vary a lot depending upon the
-- 
1.7.9.5
