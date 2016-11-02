From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v6 08/10] arch/powerpc: Enable FSL_PAMU
Date: Wed, 2 Nov 2016 22:17:32 +0200
Message-ID: <1478117854-8952-9-git-send-email-madalin.bucur@nxp.com>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@transmode.se>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
