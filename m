From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Badness in dst_release at include/net/dst.h:149
Date: Sat, 27 Nov 2004 14:02:02 +1100
Message-ID: <20041127030202.GA7054@gondor.apana.org.au>
References: <41A7ED58.7030906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41A7ED58.7030906@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 26, 2004 at 09:58:32PM -0500, Jeff Garzik wrote:
> This just appeared on my router (which Yoshfuji and Arnaldo have access to):

Jeff, could you please apply the set of ipv6 patches that Yoshfuji posted
to netdev recently? They should fix a bug that can produce exactly this
symptom.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
