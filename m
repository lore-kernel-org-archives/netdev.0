From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 0/3] ARM: dts: keystone-k2g: Add DCAN instances to 66AK2G
Date: Wed, 2 Aug 2017 15:18:19 -0500
Message-ID: <20170802201822.11532-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <ssantosh@kernel.org>, <linux@armlinux.org.uk>,
        <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add D CAN nodes to 66AK2G based SoC dtsi.

Franklin S Cooper Jr (2):
  dt-bindings: net: c_can: Update binding for clock and power-domains
    property
  ARM: configs: keystone: Enable D_CAN driver

Lokesh Vutla (1):
  ARM: dts: k2g: Add DCAN nodes

 Documentation/devicetree/bindings/net/can/c_can.txt | 13 ++++++++++++-
 arch/arm/boot/dts/keystone-k2g.dtsi                 | 18 ++++++++++++++++++
 arch/arm/configs/keystone_defconfig                 |  3 +++
 3 files changed, 33 insertions(+), 1 deletion(-)

-- 
2.9.4.dirty
