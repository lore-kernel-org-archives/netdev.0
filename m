From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 23:10:52 +0300
Message-ID: <200808192310.52457.denys@visp.net.lb>
References: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au> <48AAC884.30802@trash.net> <20080819134230.GA6043@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:57652 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888AbYHSUMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 16:12:10 -0400
In-Reply-To: <20080819134230.GA6043@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just want to report, latest net-2.6 works fine for me (intensive classes 
creation/deletion, tbf, flow classifier, htb, pfifo) , no crashes, no 
warnings.

I will test also after few days on backbone router and probably router with 
hfsc.

Thanks for great code and support :-)

