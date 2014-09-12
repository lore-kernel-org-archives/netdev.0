From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: axienet: remove unnecessary ether_setup after
 alloc_etherdev
Date: Fri, 12 Sep 2014 18:16:05 -0400 (EDT)
Message-ID: <20140912.181605.1878319812562851527.davem@davemloft.net>
References: <78ce1faf-0bf8-41bb-a30d-cecd11d82d94@BY2FFO11FD033.protection.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michals@xilinx.com, svemula@xilinx.com, anirudh@xilinx.com,
	sbhatta@xilinx.com
To: subbaraya.sundeep.bhatta@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <78ce1faf-0bf8-41bb-a30d-cecd11d82d94@BY2FFO11FD033.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>
Date: Thu, 11 Sep 2014 14:53:33 +0530

> calling ether_setup is redundant since alloc_etherdev calls
> it.
> 
> Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>

Applied.
