From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] devinet: inetdev_init out label moved after RCU
 assignment
Date: Tue, 09 Jan 2007 14:38:39 -0800 (PST)
Message-ID: <20070109.143839.45514202.davem@davemloft.net>
References: <20070105093846.GA21000@gondor.apana.org.au>
	<20070105111910.GA3650@ff.dom.local>
	<20070105112353.GA21638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, dlstevens@us.ibm.com, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932472AbXAIWik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:38:40 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20070105112353.GA21638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 5 Jan 2007 22:23:53 +1100

> On Fri, Jan 05, 2007 at 12:19:10PM +0100, Jarek Poplawski wrote:
> > 
> > Why me? (I didn't spoil this!)
> 
> You spotted the problem, so it's only fair that you get the credit :)
> 
> > Subject: [PATCH] devinet: inetdev_init out label moved after RCU assignment
> > 
> > inetdev_init out label moved after RCU assignment
> > (final suggestion by Herbert Xu)
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Thanks, looks good to me.

Applied, thanks everyone.
