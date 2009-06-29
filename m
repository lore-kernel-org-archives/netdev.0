From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 13639] New: tun regression
Date: Mon, 29 Jun 2009 08:49:42 +0800
Message-ID: <20090629004942.GB2019@gondor.apana.org.au>
References: <bug-13639-60@http.bugzilla.kernel.org/> <20090628203208.GA3022@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alessandro.guido@gmail.com,
	Oliver Hartkopp <olver@hartkopp.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60488 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753227AbZF2Atw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 20:49:52 -0400
Content-Disposition: inline
In-Reply-To: <20090628203208.GA3022@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2009 at 05:32:08PM -0300, Arnaldo Carvalho de Melo wrote:
> 
> DNS as well doesn't work here, only ping, reverted the above cset and
> got it working again (vpnc here).

This is a dup of bug 13627 which is already fixed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
