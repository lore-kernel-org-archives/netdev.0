From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] nfsroot: fix typo
Date: Fri, 11 Apr 2008 15:44:21 +0200
Message-ID: <1207921461-18269-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:23378 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758041AbYDKNyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:54:54 -0400
Received: by ti-out-0910.google.com with SMTP id 28so200372tif.23
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:54:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The word zimage was missing.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 Documentation/nfsroot.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/nfsroot.txt b/Documentation/nfsroot.txt
index 31b3291..68baddf 100644
--- a/Documentation/nfsroot.txt
+++ b/Documentation/nfsroot.txt
@@ -169,7 +169,7 @@ They depend on various facilities being available:
 3.1)  Booting from a floppy using syslinux
 
 	When building kernels, an easy way to create a boot floppy that uses
-	syslinux is to use the zdisk or bzdisk make targets which use
+	syslinux is to use the zdisk or bzdisk make targets which use zimage
       	and bzimage images respectively. Both targets accept the
      	FDARGS parameter which can be used to set the kernel command line.
 
-- 
1.5.4.4

