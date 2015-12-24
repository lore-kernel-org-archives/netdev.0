From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 0/2] r8169:Update RTL8168H PHY parameters
Date: Thu, 24 Dec 2015 21:15:25 +0800
Message-ID: <1450962927-19077-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix typo in setting PHY parameter and update the way of reading PHY register
"rg_saw_cnt".

Chunhao Lin (2):
  r8169:Fix typo in setting RTL8168H PHY parameter
  r8169:Update the way of reading RTL8168H PHY register "rg_saw_cnt"

 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.9.1
