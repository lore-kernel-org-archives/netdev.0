From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Check encap_type at config time
Date: Fri, 25 Jun 2004 10:39:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625103928.3b1b3275.davem@redhat.com>
References: <20040625121147.GA11231@gondor.apana.org.au>
	<20040625123527.GA11685@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040625123527.GA11685@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Jun 2004 22:35:27 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the patch to check encap_type at the earliest possible
> opportunity in xfrm_user/af_key.
> 
> This will allow us to assume in esp4 that the encap_type from x->encap
> is always valid.

Applied.
