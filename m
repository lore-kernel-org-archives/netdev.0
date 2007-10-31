From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Oops in 2.6.21-rc4, 2.6.23
Date: Wed, 31 Oct 2007 09:39:15 +0100
Message-ID: <20071031083915.GA1814@ff.dom.local>
References: <20071015173956.6c554387@beavis.confused.org> <20071029084232.GA2280@ff.dom.local> <20071029.014147.56411400.davem@davemloft.net> <20071030141120.GA3997@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: darko.koruga@siol.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44513 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752638AbXJaIfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 04:35:51 -0400
Content-Disposition: inline
In-Reply-To: <20071030141120.GA3997@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 03:11:20PM +0100, Jarek Poplawski wrote:
> On Mon, Oct 29, 2007 at 01:41:47AM -0700, David Miller wrote:
> ...
> > Actually, this was caused by a real bug in the SKB_WITH_OVERHEAD macro
> > definition, which Herbert Xu quickly spotted and fixed.
> > 
> > Which "I hope you've found this by yourself by now".
> > 
> 
> ...Btw, of course you have to be right, and I should find this in max.
> 12 days yet, if I'm as smart as I hope. But as for now, I really can't
> see any meaningful difference between this "buggy" SKB_WITH_OVERHEAD
> version and 'generic' 2.6.20.

OK. At last I've found "by myself", what you seemed to suggest with
such a great subtlety... So, there was this another, bugzilla thread...
And, accidentally of course, I could have been not so 100% wrong, as
expected?!

Regards,
Jarek P.
