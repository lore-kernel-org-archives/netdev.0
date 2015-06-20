From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: build warnings after merge of the net-next tree
Date: Sat, 20 Jun 2015 20:31:28 +0200
Message-ID: <20150620183128.GB3362@salvia>
References: <20150620231255.320ed133@canb.auug.org.au>
 <20150620174003.GD4683@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150620174003.GD4683@breakpoint.cc>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 20, 2015 at 07:40:03PM +0200, Florian Westphal wrote:
[...]
> > Introduced by commit:
> > 
> >   71ae0dff02d7 ("netfilter: xtables: use percpu rule counters")
> 
> Yes, sorry about this, should be fixed by dcb8f5c8139ef945cdfd
> ("netfilter: xtables: fix warnings on 32bit platforms").

There's a pending pull to address this fallout:

http://patchwork.ozlabs.org/patch/486819/

Thanks.
