From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sh_eth: couple of software reset bit cleanups
Date: Tue, 26 Apr 2016 16:07:50 -0400 (EDT)
Message-ID: <20160426.160750.287313568412301143.davem@davemloft.net>
References: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 24 Apr 2016 23:42:48 +0300

>    Here's a set of 2 patches against DaveM's 'net-next.git' repo. We clean up
> the use of the software reset bits...
> 
> [1/2] sh_eth: use EDMR_SRST_GETHER in sh_eth_check_reset()
> [2/2] sh_eth: rename ARSTR register bit

Series applied, thanks.
