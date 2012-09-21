From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Fri, 21 Sep 2012 12:17:24 +0200
Message-ID: <20120921101724.GA25347@1984>
References: <20120914120750.GA5764@1984>
 <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
 <1348058791.2761.94.camel@localhost>
 <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
 <20120920100859.GB20828@1984>
 <Pine.GSO.4.63.1209201212480.1775@stinky-local.trash.net>
 <Pine.GSO.4.63.1209201859140.14078@stinky-local.trash.net>
 <20120921010025.GA20479@1984>
 <1348220842.3103.17.camel@localhost>
 <20120921100308.GA24155@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60107 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362Ab2IUKR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 06:17:28 -0400
Content-Disposition: inline
In-Reply-To: <20120921100308.GA24155@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 12:03:08PM +0200, Pablo Neira Ayuso wrote:
> On Fri, Sep 21, 2012 at 11:47:22AM +0200, Jesper Dangaard Brouer wrote:
> > On Fri, 2012-09-21 at 03:00 +0200, Pablo Neira Ayuso wrote:
> > > On Thu, Sep 20, 2012 at 07:06:52PM +0200, Patrick McHardy wrote:
> > > > On Thu, 20 Sep 2012, Patrick McHardy wrote:
> > [cut]
> > (discussion of fixes by Patrick and Florian)
> > (...settling on Patricks second patch)
> > 
> > > Makes sense. And we can revisit this to improve it later.
> > > 
> > > I'll take this patch. I'll send a batch with updates for the nf-nat
> > > thin asap.
> > 
> > What git tree is that?
> > 
> > I'm trying to work off Pablo's nf-next tree (for my IPVS changes):
> >   git://1984.lsi.us.es/nf-next
> > 
> > But I don't see the patch in that tree ...yet.
> 
> I didn't push it yet, will do asap.

Done.

You may require git pull --rebase to get your patches up on the git
head.
