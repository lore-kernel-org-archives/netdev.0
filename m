From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] MAINTAINERS: Update qlogic networking drivers
Date: Mon, 24 Oct 2016 08:48:09 +0300
Message-ID: <1477288089-3894-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ameen.rahman@cavium.com>, <Ariel.Elior@cavium.com>,
        <harish.patil@cavium.com>, <rasesh.mody@cavium.com>,
        <Manish.Chopra@cavium.com>, <Sudarsana.Kalluru@cavium.com>,
        <rahul.verma@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55455 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750849AbcJXFsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 01:48:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following Cavium's acquisition of qlogic we need to update all the qlogic
drivers maintainer's entries to point to our new e-mail addresses,
as well as update some of the driver's maintainers as those are no longer
working for Cavium.

I would like to thank Sony Chacko and Rajesh Borundia for their support
and development of our various networking drivers.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---

 MAINTAINERS | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1fc66f0a..af299a7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2543,15 +2543,18 @@ S:	Supported
 F:	drivers/net/ethernet/broadcom/genet/
 
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
-M:	Sony Chacko <sony.chacko@qlogic.com>
-M:	Dept-HSGLinuxNICDev@qlogic.com
+M:	Rasesh Mody <rasesh.mody@cavium.com>
+M:	Harish Patil <harish.patil@cavium.com>
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/bnx2.*
 F:	drivers/net/ethernet/broadcom/bnx2_*
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-M:	Ariel Elior <ariel.elior@qlogic.com>
+M:	Yuval Mintz <Yuval.Mintz@cavium.com>
+M:	Ariel Elior <ariel.elior@cavium.com>
+M:	everest-linux-l2@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/bnx2x/
@@ -2758,7 +2761,9 @@ S:	Supported
 F:	drivers/scsi/bfa/
 
 BROCADE BNA 10 GIGABIT ETHERNET DRIVER
-M:	Rasesh Mody <rasesh.mody@qlogic.com>
+M:	Rasesh Mody <rasesh.mody@cavium.com>
+M:	Sudarsana Kalluru <sudarsana.kalluru@cavium.com>
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/brocade/bna/
@@ -8492,11 +8497,10 @@ F:	Documentation/devicetree/bindings/net/wireless/
 F:	drivers/net/wireless/
 
 NETXEN (1/10) GbE SUPPORT
-M:	Manish Chopra <manish.chopra@qlogic.com>
-M:	Sony Chacko <sony.chacko@qlogic.com>
-M:	Rajesh Borundia <rajesh.borundia@qlogic.com>
+M:	Manish Chopra <manish.chopra@cavium.com>
+M:	Rahul Verma <rahul.verma@cavium.com>
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
-W:	http://www.qlogic.com
 S:	Supported
 F:	drivers/net/ethernet/qlogic/netxen/
 
@@ -9873,33 +9877,32 @@ F:	Documentation/scsi/LICENSE.qla4xxx
 F:	drivers/scsi/qla4xxx/
 
 QLOGIC QLA3XXX NETWORK DRIVER
-M:	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
-M:	Ron Mercer <ron.mercer@qlogic.com>
-M:	linux-driver@qlogic.com
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	Documentation/networking/LICENSE.qla3xxx
 F:	drivers/net/ethernet/qlogic/qla3xxx.*
 
 QLOGIC QLCNIC (1/10)Gb ETHERNET DRIVER
-M:	Dept-GELinuxNICDev@qlogic.com
+M:	Harish Patil <harish.patil@cavium.com>
+M:	Manish Chopra <manish.chopra@cavium.com>
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/qlogic/qlcnic/
 
 QLOGIC QLGE 10Gb ETHERNET DRIVER
-M:	Harish Patil <harish.patil@qlogic.com>
-M:	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>
-M:	Dept-GELinuxNICDev@qlogic.com
-M:	linux-driver@qlogic.com
+M:	Harish Patil <harish.patil@cavium.com>
+M:	Manish Chopra <manish.chopra@cavium.com>
+M:	Dept-GELinuxNICDev@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/qlogic/qlge/
 
 QLOGIC QL4xxx ETHERNET DRIVER
-M:	Yuval Mintz <Yuval.Mintz@qlogic.com>
-M:	Ariel Elior <Ariel.Elior@qlogic.com>
-M:	everest-linux-l2@qlogic.com
+M:	Yuval Mintz <Yuval.Mintz@cavium.com>
+M:	Ariel Elior <Ariel.Elior@cavium.com>
+M:	everest-linux-l2@cavium.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/qlogic/qed/
-- 
1.9.3
