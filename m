From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v8 7/9] arch/powerpc: Enable FSL_PAMU
Date: Tue, 15 Nov 2016 10:41:07 +0200
Message-ID: <1479199269-9748-8-git-send-email-madalin.bucur@nxp.com>
References: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:45175
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S966196AbcKOIlg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 03:41:36 -0500
In-Reply-To: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 arch/powerpc/configs/dpaa.config | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/configs/dpaa.config b/arch/powerpc/configs/dpaa.config
index efa99c0..f124ee1 100644
--- a/arch/powerpc/configs/dpaa.config
+++ b/arch/powerpc/configs/dpaa.config
@@ -1 +1,2 @@
 CONFIG_FSL_DPAA=y
+CONFIG_FSL_PAMU=y
-- 
2.1.0
