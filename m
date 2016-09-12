From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v4 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Sun, 11 Sep 2016 21:49:26 -0700
Message-ID: <1473655766-31628-17-git-send-email-aditr@vmware.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:38056 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932624AbcILEuz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 00:50:55 -0400
In-Reply-To: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add maintainer info for the PVRDMA driver.

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: George Zhang <georgezhang@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
Reviewed-by: Bryan Tan <bryantan@vmware.com>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 87e23cd..fee8f1d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12615,6 +12615,13 @@ S:	Maintained
 F:	drivers/scsi/vmw_pvscsi.c
 F:	drivers/scsi/vmw_pvscsi.h
 
+VMWARE PVRDMA DRIVER
+M:	Adit Ranadive <aditr@vmware.com>
+M:	VMware PV-Drivers <pv-drivers@vmware.com>
+L:	linux-rdma@vger.kernel.org
+S:	Maintained
+F:	drivers/infiniband/hw/pvrdma
+
 VOLTAGE AND CURRENT REGULATOR FRAMEWORK
 M:	Liam Girdwood <lgirdwood@gmail.com>
 M:	Mark Brown <broonie@kernel.org>
-- 
2.7.4
