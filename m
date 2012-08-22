From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/18] netfilter: IPv6 NAT
Date: Thu, 23 Aug 2012 00:22:43 +0200
Message-ID: <20120822222243.GA10342@1984>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <20120822.022801.740821969974372752.davem@davemloft.net>
 <Pine.GSO.4.63.1208222322060.25423@stinky-local.trash.net>
 <20120822.144208.2245712403707914143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57431 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932187Ab2HVWWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 18:22:52 -0400
Content-Disposition: inline
In-Reply-To: <20120822.144208.2245712403707914143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 02:42:08PM -0700, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 22 Aug 2012 23:23:53 +0200 (MEST)
> 
> > The NAT patches depend on a couple of fixes in Pablo's latest
> > submission, if you could merge net.git into net-next.git, I can push
> > them to Pablo without creating conflicts. Thanks!
> 
> I just did that right now, should show up on kernel.org shortly.

First, I'll pass you a Netfilter batch with 10 patches asap.

Then, I'll refresh my tree and apply Patrick's NAT patches.
