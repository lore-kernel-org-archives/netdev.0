From: Florian Westphal <fw@strlen.de>
Subject: Re: [nf-next PATCH V3 0/5] netfilter: conntrack: optimization,
 remove central spinlock
Date: Thu, 6 Mar 2014 23:53:39 +0100
Message-ID: <20140306225339.GE17526@breakpoint.cc>
References: <20140303134319.2615.9293.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140303134319.2615.9293.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> This patchset is based upon Eric Dumazet's proposed patch:
>   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> I have in agreement with Eric Dumazet, taken over this patch (and
> turned it into a entire patchset).

FWIW I think that this series should be merged for 3.15, thus:

Reviewed-by: Florian Westphal <fw@strlen.de>

I see no more issues with these patches, thanks Jesper for resurrecting
Erics work.
