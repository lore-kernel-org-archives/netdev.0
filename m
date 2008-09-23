From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: patchwork for netdev
Date: Tue, 23 Sep 2008 20:44:43 +1000
Message-ID: <200809232044.44472.jk@ozlabs.org>
References: <48D2F212.50407@hp.com> <20080922.194454.05906989.davem@davemloft.net> <1222158292.12085.134.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, horms@verge.net.au,
	rick.jones2@hp.com, rdunlap@xenotime.net, netdev@vger.kernel.org,
	jeff@garzik.org, linville@tuxdriver.com, akpm@linux-foundation.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36888 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbYIWKqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 06:46:42 -0400
In-Reply-To: <1222158292.12085.134.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

> Jeremy, I CC'ed you but you may want to catch up with the whole
> thread first.

Yep, I'd like to get patchwork extended to allow 'feedback' posts to the 
lists. This is what I'm thinking:

 * Add an 'Ack' (and possibly 'Nack' and 'Comment') button for all
   logged-in users, which will send an appropriate message to the list.

 * When a maintainer uses this functionality, patchwork can update the
   state accordingly.

However, I still need to work out the exact implementation - Ideally, 
the message could be constructed with the user's own mail client (and 
saved in the standard 'sent' folder). This requires a little 
integration hackery though.

But yeah - I'm workin' on it! :)

Cheers,


Jeremy
