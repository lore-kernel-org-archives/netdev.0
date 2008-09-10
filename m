From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 20:01:51 -0700 (PDT)
Message-ID: <20080909.200151.116401721.davem@davemloft.net>
References: <20080905115506.GA26179@gondor.apana.org.au>
	<20080908.172513.162820960.davem@davemloft.net>
	<20080909143312.GA29952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36983
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751779AbYIJDB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 23:01:58 -0400
In-Reply-To: <20080909143312.GA29952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Sep 2008 00:33:12 +1000

> ipsec: Use RCU-like construct for saved state within a walk

Applied, thanks Herbert.
