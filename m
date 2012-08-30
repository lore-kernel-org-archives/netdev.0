From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/19] Cleaning up the IPv6 MTU checking in the IPVS
 xmit code, by using a common helper function __mtu_check_toobig_v6().
Date: Thu, 30 Aug 2012 03:01:22 +0200
Message-ID: <20120830010122.GA8878@1984>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
 <1346190539-9963-3-git-send-email-kaber@trash.net>
 <Pine.LNX.4.64.1208290959010.32281@ask.diku.dk>
 <Pine.GSO.4.63.1208291424050.26100@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41386 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326Ab2H3BB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2012 21:01:28 -0400
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.63.1208291424050.26100@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 29, 2012 at 02:24:39PM +0200, Patrick McHardy wrote:
> On Wed, 29 Aug 2012, Jesper Dangaard Brouer wrote:
> 
> >
> >Just a little nitpick.
> >
> >The original title/subj was:
> >"ipvs: IPv6 MTU checking cleanup and bugfix"
> >
> >And the curr/used title/subj were part of the commit text.
> 
> Sorry, must have happened while importing the patch, I noticed it
> afterwards, but was already too late.

No problem, I'll fix this.
