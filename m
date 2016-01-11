From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix some dubious code in the Renesas Ethernet
 drivers
Date: Mon, 11 Jan 2016 17:31:27 -0500 (EST)
Message-ID: <20160111.173127.388387520171868620.davem@davemloft.net>
References: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 11 Jan 2016 00:26:07 +0300

>    Here's a set of 2 patches against DaveM's 'net.git' repo. While initializing
> EMAC the code tries to respect the duplex mode both programmed into ECMR and
> stored in its own private data -- this just can't be right.
> 
> [1/2] ravb: stop reading ECMR in ravb_emac_init()
> [2/2] sh_eth: stop reading ECMR in sh_eth_dev_init()

Series applied, thanks.
