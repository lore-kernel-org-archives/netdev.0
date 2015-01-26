From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 0/2] ARM EXYNOS5 & net: add fixed phy support
Date: Mon, 26 Jan 2015 10:37:36 +0800
Message-ID: <1422239858-3452-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

These two patches adds fixed phy support using the fixed-link DT binding
for stmmac.

v1:
	- bypassing check on phy id for fixed phy (patch 2/2)

Thanks,
Ming Lei
