From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 21:08:47 +1000
Message-ID: <20100521110847.GA29878@gondor.apana.org.au>
References: <20100520172918.GA17613@shamino.rdu.redhat.com> <20100520231630.GA22593@gondor.apana.org.au> <20100521003939.GA2223@localhost.localdomain> <20100520.224944.102694876.davem@davemloft.net> <20100521105128.GA29521@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:49091 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753899Ab0EULJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 07:09:05 -0400
Content-Disposition: inline
In-Reply-To: <20100521105128.GA29521@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 06:51:28AM -0400, Neil Horman wrote:
>
> I read it, we just described the issue in diferent terms.

Yeah I wasn't clear enough with my email without an actual patch :)

Thanks for testing Neil!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
