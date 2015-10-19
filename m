From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH v2 0/3] Coding Style Cleanning
Date: Mon, 19 Oct 2015 17:02:20 +0100
Message-ID: <1445270543-2209-1-git-send-email-paulmcquad@gmail.com>
Cc: kvalo@codeaurora.org, zajec5@gmail.com, davem@davemloft.net,
	joe@perches.com, johannes.berg@intel.com, sd@queasysnail.net,
	m@bues.ch, mike.looijmans@topic.nl, khoroshilov@ispras.ru,
	cengelma@gmx.at, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmcquad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul McQuade (3):
  net: wireless: rsi: Coding Spaces
  net: wireless: b43: Coding Style
  net: wireless: b43: Statics are init to 0

 drivers/net/wireless/b43/main.c             | 8 ++++----
 drivers/net/wireless/b43/main.h             | 2 +-
 drivers/net/wireless/b43/phy_lp.c           | 2 +-
 drivers/net/wireless/b43/xmit.h             | 2 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 2 +-
 drivers/net/wireless/rsi/rsi_mgmt.h         | 4 ++--
 6 files changed, 10 insertions(+), 10 deletions(-)

-- 
2.6.1
