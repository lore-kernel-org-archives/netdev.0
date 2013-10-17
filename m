From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] netfilter updates: nf_tables pull request
Date: Thu, 17 Oct 2013 15:23:02 -0400 (EDT)
Message-ID: <20131017.152302.168119302436570514.davem@davemloft.net>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 14 Oct 2013 18:38:41 +0200

> The following patchset contains the current original nf_tables tree
> condensed in 17 patches. I have organized them by chronogical order
> since the original nf_tables code was released in 2009 and by
> dependencies between the different patches.
 ...
> There is still work to do to fully replace x_tables [4] [5] but that can
> be done incrementally by extending our netlink API. Moreover, looking at
> netfilter-devel and the amount of contributions to nf_tables we've been
> getting, I think it would be good to have it mainstream to avoid accumulating
> large patchsets skip continuous rebases.
> 
> I tried to provide a reasonable patchset, we have more than 100 accumulated
> patches in the original nf_tables tree, so I collapsed many of the small
> fixes to the main patch we had since 2009 and provide a small batch for
> review to netdev, while trying to retain part of the history.
> 
> For those who didn't give a try to nf_tables yet, there's a quick howto
> available from Eric Leblond that describes how to get things working [6].
> 
> Comments/reviews welcome.

This looks great, pulled, thanks a lot!!
