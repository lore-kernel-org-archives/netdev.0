From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/84] netfilter: netfilter update for 2.6.35
Date: Mon, 10 May 2010 23:14:27 -0700 (PDT)
Message-ID: <20100510.231427.200101684.davem@davemloft.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kaber@trash.net
Date: Mon, 10 May 2010 22:17:31 +0200

> appologies for not sending this earlier in smaller batches, as mentioned
> earlier I ran into some problems with git. Following is a first netfilter
> update for 2.6.35, containing:
 ...
> The patches won't apply cleanly because of some conflicts resolved during
> merges, please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Looks good, pulled, thanks Patrick.

Please double check that the device leak in xt_TEE pointed out by Eric
really got fixed properly in the end.

Thanks.
