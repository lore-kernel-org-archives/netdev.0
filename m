From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v5 16/16] MAINTAINERS: Update for PVRDMA driver
Date: Sat, 24 Sep 2016 16:21:40 -0700
Message-ID: <fe5e7704757254073963cd40bff5240421b1fce0.1474759181.git.aditr@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <cover.1474759181.git.aditr@vmware.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add maintainer info for the PVRDMA driver.

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: George Zhang <georgezhang@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
Reviewed-by: Bryan Tan <bryantan@vmware.com>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
Changes v4->v5:
 - Added pvrdma files to common UAPI folder.
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 87e23cd..5023dc0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12615,6 +12615,15 @@ S:	Maintained
 F:	drivers/scsi/vmw_pvscsi.c
 F:	drivers/scsi/vmw_pvscsi.h
 
+VMWARE PVRDMA DRIVER
+M:	Adit Ranadive <aditr@vmware.com>
+M:	VMware PV-Drivers <pv-drivers@vmware.com>
+L:	linux-rdma@vger.kernel.org
+S:	Maintained
+F:	drivers/infiniband/hw/pvrdma/
+F:	include/uapi/rdma/pvrdma-abi.h
+F:	include/uapi/rdma/pvrdma-uapi.h
+
 VOLTAGE AND CURRENT REGULATOR FRAMEWORK
 M:	Liam Girdwood <lgirdwood@gmail.com>
 M:	Mark Brown <broonie@kernel.org>
-- 
2.7.4
