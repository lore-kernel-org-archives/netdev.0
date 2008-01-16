From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: questions on NAPI processing latency and dropped network
	packets
Date: Wed, 16 Jan 2008 07:58:36 +0100
Message-ID: <20080116065836.GA1638@ff.dom.local>
References: <20080115202905.GA2680@ami.dom.local> <E1JEvxs-0006cZ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cfriesen@nortel.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:12299 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbYAPGwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 01:52:16 -0500
Received: by ug-out-1314.google.com with SMTP id z38so173986ugc.16
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 22:52:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <E1JEvxs-0006cZ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 11:17:08AM +1100, Herbert Xu wrote:
...
> Well people are always going to operate on this model for commercial
> reasons.  FWIW I used to work for a company that stuck to a specific
> version of the Linux kernel, and I suppose I still do even now :)
> 
> But the important thing is that if you're going to do that, then the
> cost that comes with it should be borne by the company and not the
> community.

Sure. But the most sad thing is there seems to be not so much savings
in this (unless a company isn't sure of its near future). Trying to
upgrade and test current products with current kernels, even if not
necessary, should be always useful and make developing of new products
faster and better fit (and of course, BTW, make the kernel better on
time).

Regards,
Jarek P.
