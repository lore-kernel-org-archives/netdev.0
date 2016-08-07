From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Correct CAPS mask
Date: Sun, 07 Aug 2016 00:25:00 -0700 (PDT)
Message-ID: <20160807.002500.1385616310816950633.davem@davemloft.net>
References: <1470373318-34516-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	harinik@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
	stable@vger.kernel.org
To: harini.katakam@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470373318-34516-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Fri, 5 Aug 2016 10:31:58 +0530

> USRIO and JUMBO CAPS have the same mask.
> Fix the same.
> 
> Fixes: ce721a702197 ("net: ethernet: cadence-macb: Add disabled usrio caps")
> Cc: stable@vger.kernel.org # v4.5+
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied.
