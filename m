From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge related
 ?)
Date: Mon, 06 Aug 2012 15:54:17 +0200
Message-ID: <1344261258.26674.16.camel@edumazet-glaptop>
References: <501B8792.6040605@univ-nantes.fr>
	 <1343983887.9299.817.camel@edumazet-glaptop>
	 <1344008408.4642.160.camel@deadeye.wl.decadent.org.uk>
	 <20120806091846.GA18581@gondor.apana.org.au>
	 <1344250640.26674.9.camel@edumazet-glaptop>
	 <20120806134232.GA19849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36712 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867Ab2HFNyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 09:54:23 -0400
Received: by bkwj10 with SMTP id j10so1038653bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 06:54:22 -0700 (PDT)
In-Reply-To: <20120806134232.GA19849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 21:42 +0800, Herbert Xu wrote:

> tcp_gro_complete
> 

Oops thats right, thanks ;)
