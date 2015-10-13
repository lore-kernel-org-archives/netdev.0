From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH 0/1] Fix for module license in Broadcom Phy Library
Date: Tue, 13 Oct 2015 13:40:11 -0700
Message-ID: <1444768812-31476-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
This patchset adds the module description, license & author to the
Broadcom Phy Library (drivers/net/phy/bcm-phy-lib.c) introduced by
the commit: a1cba5613edf5 ("net: phy: Add Broadcom phy library for
common interfaces")

Arun Parameswaran (1):
  net: phy: bcm-phy-lib: Fix module license issue

 drivers/net/phy/bcm-phy-lib.c | 4 ++++
 1 file changed, 4 insertions(+)

-- 
2.6.1
