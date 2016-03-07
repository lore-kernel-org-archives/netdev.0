From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 0/3] net: macb: Fix coding style issues
Date: Mon,  7 Mar 2016 08:17:36 -0800
Message-ID: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

this series deals with most of the checkpatch warnings
generated for macb. There are two BUG_ON()'s that I didn't touch, yet,
that were suggested by checkpatch, that I can address in a follow up
commit if needed.
Let me know if you want me to split the fixes differently or squash
them into one commit.

Cheers,

Moritz


Moritz Fischer (3):
  net: macb: Fix coding style error message
  net: macb: Fix more coding style issues
  net: macb: Address checkpatch 'check' suggestions

 drivers/net/ethernet/cadence/macb.c | 157 ++++++++++++++++--------------------
 1 file changed, 71 insertions(+), 86 deletions(-)

-- 
2.4.3
