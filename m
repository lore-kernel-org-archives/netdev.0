From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter fixes for 3.7-rc8
Date: Thu, 14 Feb 2013 13:18:11 -0500 (EST)
Message-ID: <20130214.131811.650216250906083038.davem@davemloft.net>
References: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Wed, 13 Feb 2013 21:38:30 +0100

> The following patchset contains three Netfilter fixes, they are:
> 
> * Fix conntrack helper re-assignment after NAT mangling if only if
>   the same helper is attached to the conntrack again, from Florian
>   Westphal.
> 
> * Don't allow the creation of conntrack entries via ctnetlink if the
>   original and reply tuples are missing, from Florian Westphal.
> 
> * Fix broken sysctl interface in nf_ct_reasm while adding netns support
>   to it, from Michal Kubecek.
> 
> Again, these are coming very late but they seem small and non-intrusive to me.
> If case your verdict is positive, you can pull this changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
