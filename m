From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] etherh: Add MAINTAINERS entry for etherh
Date: Fri,  4 Nov 2011 15:58:41 -0700
Message-ID: <1320447521-14270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Russell King <linux@arm.linux.org.uk>,
	Joe Perches <joe@perches.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:39068 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab1KDW6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 18:58:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the re-organization of Ethernet drivers, the MAINTAINERS
entry for etherh got dropped accidentally.

CC: Russell King <linux@arm.linux.org.uk>
CC: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a6afe34..ecb2299 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1032,6 +1032,7 @@ F:	arch/arm/include/asm/hardware/ioc.h
 F:	arch/arm/include/asm/hardware/iomd.h
 F:	arch/arm/include/asm/hardware/memc.h
 F:	arch/arm/mach-rpc/
+F:	drivers/net/ethernet/8390/etherh.c
 F:	drivers/net/ethernet/i825xx/ether1*
 F:	drivers/net/ethernet/seeq/ether3*
 F:	drivers/scsi/arm/
-- 
1.7.6.4
