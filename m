From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: get rid of the 2nd parameter to
 sh_eth_dev_init()
Date: Tue, 26 Apr 2016 15:22:35 -0400 (EDT)
Message-ID: <20160426.152235.1961438040028461276.davem@davemloft.net>
References: <1615196.r6Bb3HFTJZ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1615196.r6Bb3HFTJZ@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 24 Apr 2016 19:11:07 +0300

> sh_eth_dev_init()  is now always called with  'true' as the  2nd argument,
> so that there's no more sense in having 2 parameters to this function...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
