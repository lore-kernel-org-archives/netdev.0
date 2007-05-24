From: David Miller <davem@davemloft.net>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 23:40:14 -0700 (PDT)
Message-ID: <20070523.234014.130216922.davem@davemloft.net>
References: <20070523114021.GA21880@elte.hu>
	<20070523.143056.115914753.davem@davemloft.net>
	<4655256C.1030208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, herbert@gondor.apana.org.au, kernel@prachanda.info,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, tglx@linutronix.de,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754497AbXEXGkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 02:40:12 -0400
In-Reply-To: <4655256C.1030208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 24 May 2007 07:41:00 +0200

> David Miller wrote:
> >>* Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >>
> >>>[NET_SCHED]: Fix qdisc_restart return value when dequeue is empty
> >
> > Applied, thanks everyone.
> 
> 
> Even though it didn't fix this problem, this patch I sent earlier is
> also needed.

Thanks a lot for reminding me about this patch Patrick, applied.
