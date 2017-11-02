From: David Daney <david.daney@cavium.com>
Subject: [PATCH 7/7] MAINTAINERS: Add entry for drivers/net/ethernet/cavium/octeon/octeon3-*
Date: Wed,  1 Nov 2017 17:36:06 -0700
Message-ID: <20171102003606.19913-8-david.daney@cavium.com>
References: <20171102003606.19913-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        devicetree@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@mips.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171102003606.19913-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Daney <david.daney@cavium.com>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9a24f56e0451..142af33adc35 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3212,6 +3212,12 @@ W:	http://www.cavium.com
 S:	Supported
 F:	drivers/mmc/host/cavium*
 
+CAVIUM OCTEON-III NETWORK DRIVER
+M:	David Daney <david.daney@cavium.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/cavium/octeon/octeon3-*
+
 CAVIUM OCTEON-TX CRYPTO DRIVER
 M:	George Cherian <george.cherian@cavium.com>
 L:	linux-crypto@vger.kernel.org
-- 
2.13.6
