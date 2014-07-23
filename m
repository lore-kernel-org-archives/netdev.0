From: varkabhadram@gmail.com
Subject: [PATCH net-next v3 0/2] cleanup for Realtek 8139CP
Date: Wed, 23 Jul 2014 09:19:47 +0530
Message-ID: <1406087389-4436-1-git-send-email-varkabhadram@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

changes since v2:
        - making version info print once.
changes sice v1:
        - remove unused varible warning

Varka Bhadram (2):
  ethernet: realtek: use module_pci_driver
  ethernet: realtek: use pci_device_id

 drivers/net/ethernet/realtek/8139cp.c |   36 +++++++++------------------------
 1 file changed, 9 insertions(+), 27 deletions(-)

-- 
1.7.9.5
