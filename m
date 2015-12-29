From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 0/3] Fix some typos in setting hardware parameter
Date: Tue, 29 Dec 2015 22:13:36 +0800
Message-ID: <1451398419-4816-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The typos are in setting RTL8168DP, RTL8168EP and RTL8168H hardware parameters.
This series of patch fix these typos.

Chunhao Lin (3):
  r8169:Fix typo in setting RTL8168EP and RTL8168H D3cold PFM mode
  r8169:Fix typo in setting RTL8168H PHY PFM mode.
  r8169:Correct the way of setting RTL8168DP ephy

 drivers/net/ethernet/realtek/r8169.c | 27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

-- 
1.9.1
