From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT] Networking
Date: Mon, 20 Oct 2014 09:53:07 +0200
Message-ID: <20141020075307.GA3420@salvia>
References: <20141019.132314.264021750039480460.davem@davemloft.net>
 <CA+55aFz4UdVbZKPKwkesj0=1Yu7jLDP3Q3-jwe45b7gRU+0rog@mail.gmail.com>
 <20141019.210314.1388340101577924200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34655 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621AbaJTHvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 03:51:40 -0400
Content-Disposition: inline
In-Reply-To: <20141019.210314.1388340101577924200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 09:03:14PM -0400, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sun, 19 Oct 2014 17:32:15 -0700
> 
> > Looks like the module license issue was just overlooked when moving
> > the code out in commit c8d7b98bec43 ("netfilter: move nf_send_resetX()
> > code to nf_reject_ipvX modules").
> 
> I think Pablo has a patch pending to address this, and indeed he does:
> 
> 	http://marc.info/?l=linux-netdev&m=141293491712312&w=2
> 
> Pablo please push this to me soon, thanks.

I'll send you this batch today. Thanks.
