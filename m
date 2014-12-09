From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 0/9] r8169:update hardware ephy parameter
Date: Wed, 10 Dec 2014 00:45:54 +0800
Message-ID: <1418143563-7652-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update hardware ephy parameter to improve pcie compatibility.

These series of patch include the ephy update of following adapters.
rtl8168g
rtl8168gu
rtl8411b
rtl8411
rtl8168fb
rtl8168e-vl
rtl8168dp
rtl8105
rtl8402

Chunhao Lin (9):
  r8169:update rtl8168g ephy parameter
  r8169:update rtl8168gu ephy parameter
  r8169:update rtl8411b ephy parameter
  r8169:update rtl8411 ephy parameter
  r8169:update rtl8168fb ephy parameter
  r8169:update rtl8168e-vl ephy parameter
  r8169:update rtl8168dp ephy parameter
  r8169:update rtl8105e ephy parameter
  r8169:update rtl8402 ephy parameter

 drivers/net/ethernet/realtek/r8169.c | 127 +++++++++++++++++++++--------------
 1 file changed, 78 insertions(+), 49 deletions(-)

-- 
1.9.1
