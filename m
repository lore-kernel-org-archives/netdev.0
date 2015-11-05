From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter fixes for net
Date: Wed, 04 Nov 2015 20:55:26 -0500 (EST)
Message-ID: <20151104.205526.21913366211196665.davem@davemloft.net>
References: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed,  4 Nov 2015 15:00:35 +0100

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Fix crash when TEE target is used with no --oif, from Eric Dumazet.
> 
> 2) Oneliner to fix a crash on the redirect traffic to localhost
>    infrastructure when interface has not yet an address, from
>    Munehisa Kamata.
> 
> 3) Oneliner not to request module all the time from nfnetlink due to
>    wrong type value, from Florian Westphal.
> 
> I'll make sure these patches 1 and 2 hit -stable.

Pulled.

Since net-next got merged, and I fast-forwarded net to Linus's
tree, there were some minor conflicts.

Please double check my work.

Thanks.
