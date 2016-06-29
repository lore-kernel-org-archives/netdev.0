From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [linux-next] net: netcp: Fix a typo in keystone-netcp.txt
Date: Wed, 29 Jun 2016 23:36:20 +0900
Message-ID: <20160629143620.9096-1-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix a spelling typo in keystone-netcp.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/devicetree/bindings/net/keystone-netcp.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index b30ab6b5cbfa..04ba1dc34fd6 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -2,7 +2,7 @@ This document describes the device tree bindings associated with the
 keystone network coprocessor(NetCP) driver support.
 
 The network coprocessor (NetCP) is a hardware accelerator that processes
-Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsytem with a ethernet
+Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
 switch sub-module to send and receive packets. NetCP also includes a packet
 accelerator (PA) module to perform packet classification operations such as
 header matching, and packet modification operations such as checksum
-- 
2.9.0.137.gcf4c2cf
