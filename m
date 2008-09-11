From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] confused about IPSEC_MANUAL_REQID_MAX
Date: Thu, 11 Sep 2008 21:55:48 +1000
Message-ID: <20080911115548.GA22913@gondor.apana.org.au>
References: <dffc28000809090400l9617cfejc2607c6b3767417@mail.gmail.com> <E1Kdh4i-0005Om-Qc@gondolin.me.apana.org.au> <dffc28000809110122ke4cbef6j1800dd29fef1e5ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Zsolt SZALAI <zs.szalai@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45740 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751850AbYIKLzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:55:50 -0400
Content-Disposition: inline
In-Reply-To: <dffc28000809110122ke4cbef6j1800dd29fef1e5ad@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 08:22:10AM +0000, Zsolt SZALAI wrote:
> 
> I would like to switch, but it would require much time to port our
> code, that we don't have now.
> I hope af_key wont be deleted from the kernel tree in the near future,
> and then we will have time to migrate.

No it won't be deleted, certainly not for a long time.

But we do encourage people to move away from it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
