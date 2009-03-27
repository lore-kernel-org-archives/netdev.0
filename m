From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] xfrm: spin_lock() should be spin_unlock() in
	xfrm_state.c
Date: Fri, 27 Mar 2009 15:38:56 +0800
Message-ID: <20090327073856.GB27208@gondor.apana.org.au>
References: <20090326185845.2c5719b4@dhcp-100-2-144.bos.redhat.com> <20090327011654.GA24848@gondor.apana.org.au> <20090327.002413.94445791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43379 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752526AbZC0HjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:39:03 -0400
Content-Disposition: inline
In-Reply-To: <20090327.002413.94445791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 12:24:13AM -0700, David Miller wrote:
>
> I can't believe nobody hit this in all of this time :-)

Indeed, now it makes nervous everytime I type ip xfrm state :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
