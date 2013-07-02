From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cassini: Make missing firmware non-fatal
Date: Mon, 01 Jul 2013 23:48:03 -0700 (PDT)
Message-ID: <20130701.234803.1786506561267879534.davem@davemloft.net>
References: <1372634007.5155.51.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andres.Arias@PaisLinux.net, 712674@bugs.debian.org,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab3GBGsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 02:48:05 -0400
In-Reply-To: <1372634007.5155.51.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 01 Jul 2013 00:13:27 +0100

> The firmware patch for the Saturn PHY fixes a bug, but is not absolutely
> essential.  And its licence is unclear, so it is not included in all
> distributions.  Just log an error message and continue if it is missing
> or invalid.
> 
> References: http://bugs.debian.org/712674
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Jose Andres Arias Velichko <Andres.Arias@PaisLinux.net> (against 3.2)

This looks fine, applied.
