From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [Bug 13639] New: tun regression
Date: Sun, 28 Jun 2009 23:34:20 -0300
Message-ID: <20090629023420.GC3022@ghostprotocols.net>
References: <bug-13639-60@http.bugzilla.kernel.org/> <20090628203208.GA3022@ghostprotocols.net> <20090629004942.GB2019@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, alessandro.guido@gmail.com,
	Oliver Hartkopp <olver@hartkopp.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, bugzilla-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36546 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbZF2Ce1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 22:34:27 -0400
Content-Disposition: inline
In-Reply-To: <20090629004942.GB2019@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jun 29, 2009 at 08:49:42AM +0800, Herbert Xu escreveu:
> On Sun, Jun 28, 2009 at 05:32:08PM -0300, Arnaldo Carvalho de Melo wrote:
> > 
> > DNS as well doesn't work here, only ping, reverted the above cset and
> > got it working again (vpnc here).
> 
> This is a dup of bug 13627 which is already fixed.

OK, its just that I'm not using net-2.6.git, must then wait for next time
Linus pulls it.

- Arnaldo
