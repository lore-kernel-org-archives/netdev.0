From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v7 09/10] arch/powerpc: Enable FSL_FMAN
Date: Fri, 11 Nov 2016 10:20:06 +0200
Message-ID: <1478852407-27420-10-git-send-email-madalin.bucur@nxp.com>
References: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0048.outbound.protection.outlook.com ([104.47.41.48]:44112
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755668AbcKKIUi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 03:20:38 -0500
In-Reply-To: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 arch/powerpc/configs/dpaa.config | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/configs/dpaa.config b/arch/powerpc/configs/dpaa.config
index f124ee1..9ad9bc0 100644
--- a/arch/powerpc/configs/dpaa.config
+++ b/arch/powerpc/configs/dpaa.config
@@ -1,2 +1,3 @@
 CONFIG_FSL_DPAA=y
 CONFIG_FSL_PAMU=y
+CONFIG_FSL_FMAN=y
-- 
2.1.0
