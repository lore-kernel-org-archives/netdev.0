From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Thu, 14 Oct 2004 21:07:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014110742.GA7910@gondor.apana.org.au>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org> <E1CI2I2-0001sI-00@gondolin.me.apana.org.au> <20041014105757.GB12694@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20041014105757.GB12694@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 14, 2004 at 12:57:57PM +0200, Harald Welte wrote:
> 
> Ok, would you like to receive a patch that fixes the xfrm netlink
> interface to be more compatible with the netlink manpage and what
> rtnetlink does?

I have no objections at all :)

While you're at it please fix the other netlink users as well, e.g.,
tcp_diag.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
