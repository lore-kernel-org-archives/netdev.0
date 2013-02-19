From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] netfilter updates for net-next
Date: Tue, 19 Feb 2013 00:44:04 -0500 (EST)
Message-ID: <20130219.004404.1352291386944772627.davem@davemloft.net>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue, 19 Feb 2013 01:10:44 +0100

> The following patchset contain updates for your net-next tree, they are:
> 
> * Fix (for just added) connlabel dependencies, from Florian Westphal.
> 
> * Add aliasing support for conntrack, thus users can either use -m state
>   or -m conntrack from iptables while using the same kernel module, from
>   Jozsef Kadlecsik.
> 
> * Some code refactoring for the CT target to merge common code in
>   revision 0 and 1, from myself.
> 
> * Add aliasing support for CT, based on patch from Jozsef Kadlecsik.
> 
> * Add one mutex per nfnetlink subsystem, from myself.
> 
> * Improved logging for packets that are dropped by helpers, from myself.

Pulled, thanks Pablo.
