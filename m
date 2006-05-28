From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [1/4] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Sun, 28 May 2006 18:35:30 +0900 (JST)
Message-ID: <20060528.183530.71111591.yoshfuji@linux-ipv6.org>
References: <20060527.210519.119151107.yoshfuji@linux-ipv6.org>
	<E1FjxaL-0002Gv-00@gondolin.me.apana.org.au>
	<20060527.230302.85071200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49415 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932103AbWE1JfI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 May 2006 05:35:08 -0400
To: davem@davemloft.net
In-Reply-To: <20060527.230302.85071200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060527.230302.85071200.davem@davemloft.net> (at Sat, 27 May 2006 23:03:02 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > Please don't get me wrong.  What I removed here doesn't work at all to
> > begin with.  I was just pointing out the possible reason why this code
> > existed in the first place.
> 
> Right the existing code didn't work at all.  Herbert is not
> making things any worse or less functional.  The task for
> making ipv6 unloadable as a module remains equally arduous
> both before and after Herbert's changes :-)

Okay.

--yoshfuji
