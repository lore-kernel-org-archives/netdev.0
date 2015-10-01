From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net-next] netfilter: remove dead code
Date: Thu, 1 Oct 2015 11:39:29 -0300
Message-ID: <20151001143929.GA3385@x240.home>
References: <1443572700-29705-1-git-send-email-fbl@redhat.com>
 <20150930004507.GH19923@breakpoint.cc>
 <20150929.215435.823982622418043263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:25365 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbbJAOji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 10:39:38 -0400
Content-Disposition: inline
In-Reply-To: <20150929.215435.823982622418043263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 09:54:35PM -0700, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed, 30 Sep 2015 02:45:07 +0200
> 
> > Flavio Leitner <fbl@redhat.com> wrote:
> >> Remove __nf_conntrack_find() from headers.
> >> Fixes: dcd93ed4cd1 ("netfilter: nf_conntrack: remove dead code"
> > 
> > For the record: netfilter patches should go to
> > netfilter-devel@vger.kernel.org .
> > 
> > That being said, in this case I doubt Pablo minds if David takes this
> > directly, patch ts obviously correct[tm] :)

That's what I thought.

> I don't want to create any unnecessary merge hassles, so please
> resubmit this properly to netfilter-devel, thanks.

Ok, done.
http://marc.info/?l=netfilter-devel&m=144361945411969&w=2
Thanks,
fbl
