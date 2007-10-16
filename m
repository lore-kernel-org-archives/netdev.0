From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Tue, 16 Oct 2007 18:34:36 +0800
Message-ID: <20071016103435.GA10467@gondor.apana.org.au>
References: <20071014115934.13530a8a@hyperion.delvare> <E1Ih0PI-0003TX-00@gondolin.me.apana.org.au> <20071016104636.7d633bad@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4173 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758322AbXJPKe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 06:34:56 -0400
Content-Disposition: inline
In-Reply-To: <20071016104636.7d633bad@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 10:46:36AM +0200, Jean Delvare wrote:
>
> Thanks for the information. Now I'm worried that most people use
> netstat and not ss, while it seems that netstat doesn't have tcp_diag
> support. Would it make sense to add tcp_diag support to netstat? Or
> should we simply invite system admins to switch from netstat to ss
> (maybe by adding a netstat-like formatting option)?

Personally getting netstat to use inet_diag would seem to be
easier than retraining everybody's fingers to type ss :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
