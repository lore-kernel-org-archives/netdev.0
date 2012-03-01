From: Cloud Ren <cjren@qca.qualcomm.com>
Subject: [PATCH 0/3] atl1c: update some information of atl1c driver
Date: Thu, 1 Mar 2012 13:41:06 +0800
Message-ID: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	Cloud Ren <cjren@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the series is to update some information of atl1c driver. Because the old author
has left, update author informatio for maintaining. and in a upstreamed driver,
driver doesn't need version information. the version of kernel will reflect its
version.

Cloud Ren (3):
  atl1c: remove ATL1C_DRV_VERSION stuff
  atl1c: change author
  atl1c: refine driver description

 drivers/net/ethernet/atheros/atl1c/atl1c.h         |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    2 --
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   13 ++++++-------
 3 files changed, 6 insertions(+), 10 deletions(-)

-- 
1.7.7
