From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 22:21:49 +0200
Message-ID: <20080819202149.GB2533@ami.dom.local>
References: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au> <48AAC884.30802@trash.net> <20080819134230.GA6043@gondor.apana.org.au> <200808192310.52457.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.190]:31038 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbYHSUTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 16:19:47 -0400
Received: by gv-out-0910.google.com with SMTP id e6so63492gvc.37
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 13:19:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808192310.52457.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 11:10:52PM +0300, Denys Fedoryshchenko wrote:
> Just want to report, latest net-2.6 works fine for me (intensive classes 
> creation/deletion, tbf, flow classifier, htb, pfifo) , no crashes, no 
> warnings.
> 
> I will test also after few days on backbone router and probably router with 
> hfsc.
> 
> Thanks for great code and support :-)
 
Thanks for great reporting and testing Denys,
Jarek P.
