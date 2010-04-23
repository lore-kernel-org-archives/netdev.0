From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 10:40:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1004231037490.29869@ask.diku.dk>
References: <20100422.164425.171794554.davem@davemloft.net>
 <1272001478.7895.7545.camel@edumazet-laptop> <20100423.011328.107238355.davem@davemloft.net>
 <20100423.011845.254684857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com,
	Patrick McHardy <kaber@trash.net>, xiaosuo@gmail.com,
	netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100423.011845.254684857.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2010, David Miller wrote:

> This all reminds me of the namespace bug we dealt with
> a month or two ago.
>
> Jesper, you don't happen to be using network namespaces are you?

No, I don't use network namespaces.
(In .config CONFIG_NAMESPACES is not set.)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
