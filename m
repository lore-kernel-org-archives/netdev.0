From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] netfilter: Compress hook function signatures.
Date: Sat, 04 Apr 2015 11:54:49 -0400 (EDT)
Message-ID: <20150404.115449.726785874523228309.davem@davemloft.net>
References: <20150403.220734.1272465850706339981.davem@davemloft.net>
	<20150404114928.GA3829@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150404114928.GA3829@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 4 Apr 2015 13:49:28 +0200

> Nice series. If you route them through net-next, please add:
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Ok, thanks for reviewing Pablo.  I'll take them through my tree
as it will make the okfn() signature change simpler to just add
on top.

> Regarding Jiri's okfn() signature changes, please let me know on those
> patches, they will simplify a patchset I'll submit soon. And count on
> me to help on that change too, of course.

I'm working on reworking Jiri's submission right now, but I need to be
careful about the nf_queue.c stuff so it will take a day or two.

I will post a series and at a minimum wait for your review.

Thanks again Pablo.

