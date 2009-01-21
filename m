From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Wed, 21 Jan 2009 14:40:54 -0800 (PST)
Message-ID: <20090121.144054.70937985.davem@davemloft.net>
References: <1232523247-6893-1-git-send-email-timo.teras@iki.fi>
	<20090121223329.GA8522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753218AbZAUWkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:40:52 -0500
In-Reply-To: <20090121223329.GA8522@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jan 2009 09:33:29 +1100

> Timo Teras <timo.teras@iki.fi> wrote:
> > Parse and send SADB_X_EXT_NAT_T_OA along with other NAT-T extensions.
> > 
> > Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> Whatever application that you have in mind that's going to use
> this should switch over to netlink.

Agreed, I won't be applying this patch.
