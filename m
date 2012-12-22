From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/2] cpts fixes for v3.8-rc2
Date: Sat, 22 Dec 2012 20:41:07 +0100
Message-ID: <cover.1356204860.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new cpts driver has two small issues, but it otherwise seems to be
working in -rc1.

Thanks,
Richard


Richard Cochran (2):
  cpts: fix build error by removing useless code.
  cpts: fix a run time warn_on.

 drivers/net/ethernet/ti/cpts.c |    2 +-
 drivers/net/ethernet/ti/cpts.h |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

-- 
1.7.2.5

