From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Fri, 5 Jun 2015 11:52:27 +0800
Message-ID: <20150605035227.GA527@gondor.apana.org.au>
References: <20150514055824.GB6058@gondor.apana.org.au>
 <20150515.130257.1322224469755323983.davem@redhat.com>
 <20150516131628.GA981@gondor.apana.org.au>
 <20150516.171019.1206903516753105739.davem@davemloft.net>
 <20150604162727.GA2670@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	tgraf@suug.ch, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56180 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbFEFVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 01:21:10 -0400
Content-Disposition: inline
In-Reply-To: <20150604162727.GA2670@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2015 at 09:27:27AM -0700, Guenter Roeck wrote:
>
> sorry for bothering you - I don't see this patch in any of your trees,
> and it is marked as "changes requested" in patchwork. Did I look
> at the wrong places, do you still plan to apply the patch as-is,
> or do you expect some changes ?

I just looked up the patchwork entry and it actually says "not
applicable" which is correct:

https://patchwork.ozlabs.org/patch/473041/

Because the patch only applies to stable and is not needed in either
net or net-next.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
