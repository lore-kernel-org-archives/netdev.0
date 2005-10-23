From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG]NULL pointer dereference in ipv6_get_saddr()
Date: Sun, 23 Oct 2005 21:25:33 +1000
Message-ID: <E1ETdyn-0005tM-00@gondolin.me.apana.org.au>
References: <20051019.012157.11460212.yoshfuji@linux-ipv6.org>
Cc: yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750785AbVJWL05@vger.kernel.org>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20051019.012157.11460212.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
>
> I think this is already fixed in head.
> I don't remember if we pushed this to stable...

Yep it was fixed by c62dba9011b93fd88fde929848582b2a98309878.

I agree that we should've pushed it to stable.  Unfortunately it
might be too late now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
