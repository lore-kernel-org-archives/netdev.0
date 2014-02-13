From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: use ETH_ZLEN instead of home-grown #define
Date: Thu, 13 Feb 2014 18:10:24 -0500 (EST)
Message-ID: <20140213.181024.1230943968416385018.davem@davemloft.net>
References: <201402140305.42833.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201402140305.42833.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 14 Feb 2014 03:05:42 +0300

> The driver #define's and uses ETHERSMALL macro for the minimum Ethernet frame
> size for which we have a standard macro ETH_ZLEN.  Use the latter  instead of
> the home-grown one.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
