From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: rearrange dma descriptor
Date: Tue, 22 Apr 2014 16:07:50 -0400 (EDT)
Message-ID: <20140422.160750.990805464756256505.davem@davemloft.net>
References: <000601cf5afd$ab2e55c0$018b0140$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	ks.giri@samsung.com, vipul.pandya@samsung.com
To: bh74.an@samsung.com
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <000601cf5afd$ab2e55c0$018b0140$%an@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>
Date: Fri, 18 Apr 2014 20:59:36 +0900

> This patch moves cksum_ctl to tx_rd_des23 from cksum_pktlen for correct checksum 
> offloading and modifies size for Tx/Rx descriptor.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied, thanks.
