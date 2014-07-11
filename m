From: varkabhadram@gmail.com
Subject: [PATCH net-next 0/8] cleanup for AMD811E ethernet driver
Date: Fri, 11 Jul 2014 13:05:02 +0530
Message-ID: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This series cleanup for AMD811E ethernet driver

Varka Bhadram (8):
  ethernet: amd: move amd111e_remove_one after probe
  ethernet: amd: use devm_ioremap()
  ethernet: amd: dynamic debug fixes
  ethernet: amd: fix comment styles
  ethernet: amd: move pci device ids
  ethernet: amd: fix 'foo* bar'
  ethernet: amd: fix spaces and few coding styles
  ethernet: amd: switch case fixes

 drivers/net/ethernet/amd/amd8111e.c |  993 +++++++++++++++++------------------
 1 file changed, 484 insertions(+), 509 deletions(-)

-- 
1.7.9.5
