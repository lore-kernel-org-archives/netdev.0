From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 23 Sep 2015 11:15:34 -0700 (PDT)
Message-ID: <20150923.111534.560140422263992933.davem@davemloft.net>
References: <1442401882.4116.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1443025932-30386-1-git-send-email-matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: matteo@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443025932-30386-1-git-send-email-matteo@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matteo Croce <matteo@openwrt.org>
Date: Wed, 23 Sep 2015 18:32:12 +0200

> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.
> 
> Signed-off-by: Matteo Croce <matteo@openwrt.org>

I don't want to see any more submissions of this feature patch, sorry.

I am convinced, based upon other's arguments, that netfilter can
provide this facility wholly.

So until you can convince us otherwise, your patch is inappropriate.

Thanks.
