From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Wed, 20 Dec 2006 10:52:19 +1100
Message-ID: <E1Gwokt-00050T-00@gondolin.me.apana.org.au>
References: <20061219103756.38f7426c@freekitty>
Cc: mingo@elte.hu, akpm@osdl.org, wenji@fnal.gov,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1481 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751813AbWLSXw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 18:52:59 -0500
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20061219103756.38f7426c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> I noticed this bit of discussion in tcp_recvmsg. It implies that a better
> queuing policy would be good. But it is confusing English (Alexey?) so
> not sure where to start.

Actually I think the comment says that the current code isn't the
most elegant but is more efficient.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
