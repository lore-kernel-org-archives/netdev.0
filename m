From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/2] MAINTAINERS: add Qualcomm EMAC network driver maintainer
Date: Wed, 13 Apr 2016 12:59:53 -0500
Message-ID: <1460570393-19838-2-git-send-email-timur@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver was originally written by Gilad Avidov, but it's now
being supported by Timur Tabi.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4851f02..8c580f8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9128,6 +9128,13 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git
 S:	Supported
 F:	drivers/net/wireless/ath/ath10k/
 
+QUALCOMM TECHNOLOGIES EMAC NETWORK DRIVER
+M:	Timur Tabi <timur@codeaurora.org>
+R:	Gilad Avidov <gavidov@codeaurora.org>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/qualcomm/emac/
+
 QUALCOMM HEXAGON ARCHITECTURE
 M:	Richard Kuo <rkuo@codeaurora.org>
 L:	linux-hexagon@vger.kernel.org
-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
