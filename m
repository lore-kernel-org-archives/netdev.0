From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
 delayed_work
Date: Sat, 03 May 2008 18:38:10 -0700 (PDT)
Message-ID: <20080503.183810.135633829.davem@davemloft.net>
References: <20080502.165455.24687234.davem@davemloft.net>
	<20080503144647.GF3986@hack>
	<20080503150606.GA26898@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbYEDBiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 21:38:10 -0400
In-Reply-To: <20080503150606.GA26898@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 3 May 2008 23:06:06 +0800

> On Sat, May 03, 2008 at 10:46:49PM +0800, WANG Cong wrote:
> > 
> > I will try if I can set up one, then test it.
> 
> I'll throw them into my test systems here and see if they break.

Thanks Herbert.
