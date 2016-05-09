From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sh_eth: couple of software reset bit cleanups
Date: Mon, 09 May 2016 00:15:51 -0400 (EDT)
Message-ID: <20160509.001551.992827306777802470.davem@davemloft.net>
References: <1808900.MGlUzc8O9C@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1808900.MGlUzc8O9C@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 08 May 2016 00:06:53 +0300

>    Here's a set of 2 patches against DaveM's 'net-next.git' repo. We can save
> on the repetitive chip reset code...
> 
> [1/2] sh_eth: call sh_eth_tsu_write() from sh_eth_chip_reset_giga()
> [2/2] sh_eth: reuse sh_eth_chip_reset()

Series applied, thanks.
