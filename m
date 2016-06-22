From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 5/5] be2net: update be2net maintainers list
Date: Wed, 22 Jun 2016 08:54:57 -0400
Message-ID: <1466600097-1641-6-git-send-email-sathya.perla@broadcom.com>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752547AbcFVMzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:23 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes Padmanabh's name from the maintainers list as he's no
longer with the company. It also adds the driver name on the headline to
make it easy to lookup the maintainers list by the driver name.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 50f69ba..cab9975 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10280,10 +10280,9 @@ W:	http://www.avagotech.com
 S:	Supported
 F:	drivers/scsi/be2iscsi/
 
-Emulex 10Gbps NIC BE2, BE3-R, Lancer, Skyhawk-R DRIVER
+Emulex 10Gbps NIC BE2, BE3-R, Lancer, Skyhawk-R DRIVER (be2net)
 M:	Sathya Perla <sathya.perla@broadcom.com>
 M:	Ajit Khaparde <ajit.khaparde@broadcom.com>
-M:	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
 M:	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
 M:	Somnath Kotur <somnath.kotur@broadcom.com>
 L:	netdev@vger.kernel.org
-- 
2.4.1
