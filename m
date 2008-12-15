From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11]: error/return path joining
Date: Sun, 14 Dec 2008 23:20:22 -0800 (PST)
Message-ID: <20081214.232022.260565410.davem@davemloft.net>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
	<E1LBoyA-00068c-LP@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751788AbYLOHUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 02:20:21 -0500
In-Reply-To: <E1LBoyA-00068c-LP@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Dec 2008 22:17:06 +1100

> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > Less copy-paste and even saves some bytes here and there though
> > the amount are not earth-shattering, ~20 bytes at most (x86_64).
> 
> Nice clean-up, thanks Ilpo!

Agreed, I've applied it all to net-next-2.6

Thanks Ilpo.
