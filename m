From: "David S. Miller" <davem@redhat.com>
Subject: Re: [SCTP] Fix incestuous header relations
Date: Sat, 29 Nov 2003 14:09:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031129140919.5bd9e73a.davem@redhat.com>
References: <20031129220623.GA11019@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031129220623.GA11019@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 Nov 2003 09:06:23 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch fixes the sm.h + sctp.h inclusion loop by including sm.h only
> in the files that need it.

Thanks.

I think 2.4.x has the same problem, could you cook me up a patch
for there too?
