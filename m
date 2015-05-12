From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH] Update be2net maintainers' email addresses
Date: Tue, 12 May 2015 02:13:50 -0400
Message-ID: <1431411230-3492-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:55173 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752437AbbELGIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 02:08:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emulex developers' email addresses are now "@avagotech" instead of
"@emulex". I'm also replacing Subbu with Padmanabh and Sriharsha in the
maintainers list. The driver's heading was outdated and did not include
some of the chip types (BE3, Lancer and Skyhawk) that the driver has
been supporting for a longtime. I've updated this too.

Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 MAINTAINERS | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index fa4e59d..85bd662 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8799,10 +8799,11 @@ W:	http://www.emulex.com
 S:	Supported
 F:	drivers/scsi/be2iscsi/
 
-SERVER ENGINES 10Gbps NIC - BladeEngine 2 DRIVER
-M:	Sathya Perla <sathya.perla@emulex.com>
-M:	Subbu Seetharaman <subbu.seetharaman@emulex.com>
-M:	Ajit Khaparde <ajit.khaparde@emulex.com>
+Emulex 10Gbps NIC BE2, BE3-R, Lancer, Skyhawk-R DRIVER
+M:	Sathya Perla <sathya.perla@avagotech.com>
+M:	Ajit Khaparde <ajit.khaparde@avagotech.com>
+M:	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
+M:	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
 L:	netdev@vger.kernel.org
 W:	http://www.emulex.com
 S:	Supported
-- 
2.2.0
