From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] IPv6 Update for net-2.6.19, Take 2
Date: Fri, 22 Sep 2006 14:46:38 -0700 (PDT)
Message-ID: <20060922.144638.42781542.davem@davemloft.net>
References: <20060921.155952.14019351.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59818
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964813AbWIVVqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 17:46:21 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060921.155952.14019351.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 21 Sep 2006 15:59:52 +0900 (JST)

>     [IPV6] NDISC: Handle NDP messages to proxied addresses.
>     [IPV6]: Don't forward packets to proxied link-local address.
>     [IPV6] NDISC: Avoid updating neighbor cache for proxied address in receiving NA.
>     [IPV6] NDISC: Set per-entry is_router flag in Proxy NA.
>     [IPV6] NDISC: Add proxy_ndp sysctl.
>     [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
>     [IPV6] NDISC: Fix is_router flag setting.
>     [IPV6] ADDRCONF: Allow non-DAD'able addresses.
>     [IPV6] ADDRCONF: Mobile IPv6 Home Address support.

All applied as patches, thank you.

I'm also rebasing the net-2.6.19 tree so I can push it
cleanly to Linus, so it may take a while for these
changes to show up on kernel.org which I do that work.
