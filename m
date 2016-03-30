From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH v3 0/5] macb: Codingstyle cleanups
Date: Tue, 29 Mar 2016 19:11:10 -0700
Message-ID: <1459303875-3362-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

resending almost unchanged v2 here:

Changes from v2:
* Rebased onto net-next
* Changed 5th patches commit message
* Added Nicholas' and Michal's Acked-Bys

Changes from v1:
* Backed out variable scope changes
* Separated out ether_addr_copy into it's own commit
* Fixed typo in comments as suggested by Joe

Cheers,

    Moritz

Moritz Fischer (5):
  net: macb: Fix coding style error message
  net: macb: Fix coding style warnings
  net: macb: Fix coding style suggestions
  net: macb: Use ether_addr_copy over memcpy
  net: macb: Fix simple typo

 drivers/net/ethernet/cadence/macb.c | 152 ++++++++++++++++--------------------
 1 file changed, 69 insertions(+), 83 deletions(-)

-- 
2.7.4
