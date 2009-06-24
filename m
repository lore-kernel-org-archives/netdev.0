From: David Miller <davem@davemloft.net>
Subject: Re: ipsec: Fix name of CAST algorithm
Date: Wed, 24 Jun 2009 03:56:03 -0700 (PDT)
Message-ID: <20090624.035603.135626656.davem@davemloft.net>
References: <20090624105146.GA21355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53903
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751602AbZFXKz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 06:55:59 -0400
In-Reply-To: <20090624105146.GA21355@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Jun 2009 18:51:46 +0800

> ipsec: Fix name of CAST algorithm
> 
> Our CAST algorithm is called cast5, not cast128.  Clearly nobody
> has ever used it :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks!
