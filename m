From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 17:39:02 +0800
Message-ID: <20090226093902.GA12753@gondor.apana.org.au>
References: <1BAC364C-FDC7-4DD6-A54C-BD6B1DDA4D74@sevsky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denis Romanenko <ash@sevsky.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751412AbZBZJjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 04:39:08 -0500
Content-Disposition: inline
In-Reply-To: <1BAC364C-FDC7-4DD6-A54C-BD6B1DDA4D74@sevsky.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Romanenko <ash@sevsky.net> wrote:
> I have high loaded router - about 1.2 Gbps
> 
> after reboot on new kernel - 2.6.27.17 i have messages in dmesg
> 
> WARNING: at kernel/softirq.c:136 local_bh_enable+0x36/0xab()

So somebody disabled the IRQs on us, the question is who?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
