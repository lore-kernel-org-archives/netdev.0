From: "David S. Miller" <davem@redhat.com>
Subject: Re: [1/2] [IPSEC] Remove unnecessary inet_ecn.h inclusions
Date: Mon, 2 Aug 2004 17:09:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802170930.2073894f.davem@redhat.com>
References: <20040802093153.GA19706@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040802093153.GA19706@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Aug 2004 19:31:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I should've removed the inet_ecn.h inclusions in that change as the
> ECN code has been moved to xfrm[46]_output.c.  This patch does exactly
> that.

Ok, applied.
