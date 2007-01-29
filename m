From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Mon, 29 Jan 2007 11:38:08 +0100
Message-ID: <20070129103808.GB1652@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au> <20070129082616.GA1652@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43033 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752556AbXA2Kfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 05:35:44 -0500
Content-Disposition: inline
In-Reply-To: <20070129082616.GA1652@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 09:26:16AM +0100, Jarek Poplawski wrote:
...
> So this patch is changing it to ipv6 way. It seems to
> be quite brave. I think there was some reason to do
> this "old way" and I hope consequences were analyzed.
...

But since Alexey Kuznetsov accepted this change too,
they surely were. Let's forget about my doubts.

Sorry for disturbing,
Jarek P.
