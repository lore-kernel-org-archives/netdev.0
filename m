From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [nf-next PATCH V3 0/5] netfilter: conntrack: optimization,
 remove central spinlock
Date: Thu, 06 Mar 2014 15:37:57 -0800
Message-ID: <1394149077.27473.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140303134319.2615.9293.stgit@dragon>
	 <20140306225339.GE17526@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140306225339.GE17526@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 23:53 +0100, Florian Westphal wrote:
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > This patchset is based upon Eric Dumazet's proposed patch:
> >   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> > I have in agreement with Eric Dumazet, taken over this patch (and
> > turned it into a entire patchset).
> 
> FWIW I think that this series should be merged for 3.15, thus:
> 
> Reviewed-by: Florian Westphal <fw@strlen.de>
> 
> I see no more issues with these patches, thanks Jesper for resurrecting
> Erics work.
> --

Indeed, thanks so much Jesper !


