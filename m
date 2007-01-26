From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 15:05:33 +0100
Message-ID: <20070126140533.GA3158@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au> <20070126110235.GD1639@ff.dom.local> <20070126131808.GE1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:52483 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965688AbXAZODF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 09:03:05 -0500
Content-Disposition: inline
In-Reply-To: <20070126131808.GE1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 02:18:08PM +0100, Jarek Poplawski wrote:
...
> I've only now read the original thread of this problem
> and this long note about security. I need more time to
> understand this, but now I'm not sure Masayuki's server
> isn't doing something against the policy of this note

This would be socket case then (not server), sorry. 

Jarek P.
