From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Sun, 16 Nov 2008 01:24:09 -0800 (PST)
Message-ID: <20081116.012409.120507131.davem@davemloft.net>
References: <20081104.145242.112948002.davem@davemloft.net>
	<E1L1dgo-0007pG-SL@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@blueteddy.net, daniel.blueman@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751706AbYKPJYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 04:24:10 -0500
In-Reply-To: <E1L1dgo-0007pG-SL@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 16 Nov 2008 17:13:06 +0800

> David Miller <davem@davemloft.net> wrote:
> >
> > This is because TSO, which is on by default, doesn't support ECN
> > in many implementations.
> 
> Dave, we fixed that ages ago.

I know, Michael Chan corrected me in a followup posting :)
