From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Mon, 26 Nov 2007 10:47:50 +0800
Message-ID: <E1IwU0k-00062B-00@gondolin.me.apana.org.au>
References: <MDEHLPKNGKAHNMBLJOLKCENAIGAC.davids@webmaster.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davids@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1346 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754000AbXKZCrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 21:47:53 -0500
In-Reply-To: <MDEHLPKNGKAHNMBLJOLKCENAIGAC.davids@webmaster.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Schwartz <davids@webmaster.com> wrote:
>
> Exactly. But *he* doesn't need to check that checksum, given that he already
> got the packet, since he has an upper-level checksum. He is not saying that
> his reasoning applies to everyone, just that it applies to him. He is not
> talking about disabling the send checksum, but the receive checksum. He
> knows that he does not need it.

You must be in some other thread because this one started with
a patch to disable sender checksums.

Oh and please do keep CCs on this list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
