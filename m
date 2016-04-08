From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [linux-next] Doc: networking: Fix typo in dsa
Date: Sat,  9 Apr 2016 00:00:25 +0900
Message-ID: <1460127625-6956-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, corbet@lwn.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix typos in Documentation/networking/dsa.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/networking/dsa/bcm_sf2.txt | 2 +-
 Documentation/networking/dsa/dsa.txt     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/dsa/bcm_sf2.txt b/Documentation/networking/dsa/bcm_sf2.txt
index d999d0c1c5b8..eba3a2431e91 100644
--- a/Documentation/networking/dsa/bcm_sf2.txt
+++ b/Documentation/networking/dsa/bcm_sf2.txt
@@ -38,7 +38,7 @@ Implementation details
 ======================
 
 The driver is located in drivers/net/dsa/bcm_sf2.c and is implemented as a DSA
-driver; see Documentation/networking/dsa/dsa.txt for details on the subsytem
+driver; see Documentation/networking/dsa/dsa.txt for details on the subsystem
 and what it provides.
 
 The SF2 switch is configured to enable a Broadcom specific 4-bytes switch tag
diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 3b196c304b73..36f905d9c77c 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -334,7 +334,7 @@ more specifically with its VLAN filtering portion when configuring VLANs on top
 of per-port slave network devices. Since DSA primarily deals with
 MDIO-connected switches, although not exclusively, SWITCHDEV's
 prepare/abort/commit phases are often simplified into a prepare phase which
-checks whether the operation is supporte by the DSA switch driver, and a commit
+checks whether the operation is supported by the DSA switch driver, and a commit
 phase which applies the changes.
 
 As of today, the only SWITCHDEV objects supported by DSA are the FDB and VLAN
-- 
2.8.0
