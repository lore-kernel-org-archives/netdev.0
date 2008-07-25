From: David Miller <davem@davemloft.net>
Subject: Re: ipsec: ipcomp - Decompress into frags if necessary
Date: Fri, 25 Jul 2008 03:55:01 -0700 (PDT)
Message-ID: <20080725.035501.47770769.davem@davemloft.net>
References: <20080725074328.GB16747@gondor.apana.org.au>
	<20080725.025801.229691344.davem@davemloft.net>
	<20080725104603.GA17974@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbYGYKzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:55:03 -0400
In-Reply-To: <20080725104603.GA17974@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Jul 2008 18:46:03 +0800

> On Fri, Jul 25, 2008 at 02:58:01AM -0700, David Miller wrote:
> > So perhaps it wants a WARN_ON :-)
> 
> There is one :)

Indeed, I even read that thing as I was composing my original
reply, hehe.
