From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC v2 0/5] netfilter reverse path filter matches
Date: Wed, 28 Sep 2011 23:23:58 +0200
Message-ID: <20110928212358.GA13047@Chamillionaire.breakpoint.cc>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
 <20110928211847.GC2761@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110928211847.GC2761@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > Kernel patches are located in the 'xt_rpfilter_5' branch on
> > http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/nf-next.git
> > (patches will be sent as followup to this email).
> > 
> > [ in case you are wondering: the earlier xt_rpfilter version was
> >   removed -- causes too many module  dependency issues and most of the
> >   code cannot be shared anyway ].
> 
> This involves other net changes, I'd like to get an ack from David
> before applying this. Or let me know if it's better to follow the
> netdev path.

Pablo, please do not apply these patches, I have newer versions
available.

David, it would be nice if you could indicate how these patches
should be merged (ie. via net-next or netfilter-next).

[ in case there are objections, I'd like to hear about those too :-) ]

Thanks,
Florian
