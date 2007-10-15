From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] [NETFILTER]: Replace sk_buff ** with sk_buff *
Date: Mon, 15 Oct 2007 01:27:08 -0700 (PDT)
Message-ID: <20071015.012708.74731580.davem@davemloft.net>
References: <20071014042604.GA11431@gondor.apana.org.au>
	<E1Igv4v-00031H-00@gondolin.me.apana.org.au>
	<20071014095541.GA13222@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752641AbXJOI1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:27:06 -0400
In-Reply-To: <20071014095541.GA13222@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Oct 2007 17:55:41 +0800

> On Sun, Oct 14, 2007 at 12:27:49PM +0800, Herbert Xu wrote:
> > [NETFILTER]: Replace sk_buff ** with sk_buff *
> >
> >  74 files changed, 469 insertions(+), 503 deletions(-)
> 
> Between me going to bed last night and waking up this morning,
> my editor wandered off causing half of the patch to disappear :)
> 
> Here is the corrected version.

That looks a lot better, I've applied all 10 patches,
thanks Herbert.
