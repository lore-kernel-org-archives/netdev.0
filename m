From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net-next
Date: Tue, 10 Mar 2015 12:49:05 -0400 (EDT)
Message-ID: <20150310.124905.650052643076658947.davem@davemloft.net>
References: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 10 Mar 2015 16:46:19 +0100

> The following batch contains a couple of fixes to address some fallout
> from the previous pull request, they are:
> 
> 1) Address link problems in the bridge code after e5de75b. Fix it by
>    using rcu hook to address to avoid ifdef pollution and hard
>    dependency between bridge and br_netfilter.
> 
> 2) Address sparse warnings in the netfilter reject code, patch from
>    Florian Westphal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo.
