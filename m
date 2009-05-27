From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/04: netfilter fixes
Date: Wed, 27 May 2009 15:52:35 -0700 (PDT)
Message-ID: <20090527.155235.79198381.davem@davemloft.net>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 27 May 2009 16:35:24 +0200 (MEST)

> following are four netfilter fixes for 2.6.30, containing:
> 
> - a patch from Jozsef to fix accepting invalid RST packets in TCP conntrack
> - a patch from Pablo to properly propagate DCCP conntrack state changes
> - a patch from Jesper to fix an invalid return value in a xt_hashlimit
>   seq_file function
> - another patch from Pablo to fix undersized skb allocation in nfnetlink_log
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Pulled, thanks Patrick.

In the future, can you please explicitly specify the branch name, even
if it is just 'master', in your GIT URLs for me to pull from?

GIT requires that it always be specified, therefore if you put it
there at the end of the URL I can just cut and paste it into my
command line.

Thanks!
