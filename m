From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 15:39:37 +0800
Message-ID: <20081005073937.GB13323@gondor.apana.org.au>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au> <20081005065509.GA2538@ami.dom.local> <20081005065648.GA13113@gondor.apana.org.au> <20081005071238.GA2752@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57259 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752575AbYJEHjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 03:39:45 -0400
Content-Disposition: inline
In-Reply-To: <20081005071238.GA2752@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 09:12:38AM +0200, Jarek Poplawski wrote:
>
> Just reading this code (plus the comment). Why would anybody bother 
> with something so complex like this if something like your idea is
> rather straightforward? But, needed or not, my point is it would be
> nice to comment that this patch changes this behavior btw.

I'm sorry but I don't have time to consider such hypotheticals.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
