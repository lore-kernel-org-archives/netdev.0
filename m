From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: kill useless initializers
Date: Mon, 14 Mar 2016 15:50:46 -0400 (EDT)
Message-ID: <20160314.155046.1353609992563150519.davem@davemloft.net>
References: <2737382.tXjN0OZRaC@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2737382.tXjN0OZRaC@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Mar 2016 01:29:45 +0300

> Some of the local variable intializers in the driver turned out to be
> pointless,  kill 'em.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks Sergei.
