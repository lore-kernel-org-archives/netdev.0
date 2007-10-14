From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] [IPV6]: Kill sk_buff ** usage on input path
Date: Sun, 14 Oct 2007 22:46:49 +0800
Message-ID: <20071014144649.GA14792@gondor.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4v-00031H-00@gondolin.me.apana.org.au> <20071014095541.GA13222@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Tho
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1740 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751127AbXJNOrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 10:47:31 -0400
Content-Disposition: inline
In-Reply-To: <20071014095541.GA13222@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 14, 2007 at 05:55:41PM +0800, Herbert Xu wrote:
>
> [NETFILTER]: Replace sk_buff ** with sk_buff *

Following on from that work, I've done the same thing to the
IPv6 input path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
