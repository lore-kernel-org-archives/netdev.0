From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/05: xtables: document minimal required version
Date: Tue, 15 Dec 2009 17:14:28 +0100 (MET)
Message-ID: <20091215161427.4146.7486.sendpatchset@x2.localnet>
References: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 7a92263705435d046d37a0990d0edfcb517f7ad3
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Dec 14 14:52:10 2009 +0100

    netfilter: xtables: document minimal required version
    
    For both .33 and .32-stable.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/Documentation/Changes b/Documentation/Changes
index 6d0f1ef..f08b313 100644
--- a/Documentation/Changes
+++ b/Documentation/Changes
@@ -49,6 +49,8 @@ o  oprofile               0.9                     # oprofiled --version
 o  udev                   081                     # udevinfo -V
 o  grub                   0.93                    # grub --version
 o  mcelog		  0.6
+o  iptables               1.4.1                   # iptables -V
+
 
 Kernel compilation
 ==================
