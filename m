From: David Miller <davem@davemloft.net>
Subject: Re: gre: fix copy and paste error
Date: Fri, 10 Oct 2008 12:10:37 -0700 (PDT)
Message-ID: <20081010.121037.91095578.davem@davemloft.net>
References: <48EF7AC0.6080104@trash.net>
	<20081010155732.GA32182@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761938AbYJJTLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 15:11:01 -0400
In-Reply-To: <20081010155732.GA32182@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 10 Oct 2008 23:57:32 +0800

> On Fri, Oct 10, 2008 at 05:54:40PM +0200, Patrick McHardy wrote:
> 
> > commit c7d32967f53c4d3ded69f0e645b7c0848ac8cb1b
> > Author: Patrick McHardy <kaber@trash.net>
> > Date:   Fri Oct 10 17:53:36 2008 +0200
> > 
> >     gre: fix copy and paste error
> >     
> >     The flags are dumped twice, the keys not at all.
> >     
> >     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Good catch.
> 
> Thanks Patrick!

Applied, thanks everyone.
