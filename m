From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/5] fix send buffer check
Date: Fri, 9 Nov 2007 20:24:16 +0800
Message-ID: <20071109122416.GC27984@gondor.apana.org.au>
References: <47264E2D.4080109@redhat.com> <47264F2D.3010105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4492 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751523AbXKIMZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 07:25:31 -0500
Content-Disposition: inline
In-Reply-To: <47264F2D.3010105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 05:22:53PM -0400, Hideo AOKI wrote:
> This patch introduces sndbuf size check before memory allocation for
> send buffer.

Looks good, what about IPv6?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
