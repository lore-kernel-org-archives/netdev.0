From: "David S. Miller" <davem@redhat.com>
Subject: Re: [AH4] Harmonisation of output function
Date: Mon, 5 Jul 2004 16:07:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705160729.2986bce2.davem@redhat.com>
References: <20040702130652.GA20334@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040702130652.GA20334@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2 Jul 2004 23:06:52 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is another step towards the union of the tunnel mode encapsulation
> between transforms.  As there are significant differences between the
> tunnel encapsulation of IPv4 and IPv6, I'll be dealing with IPv4 only
> for now.
> 
> This particular patch rearranges the code in ah_output to isolate the
> tunnel mode encapsulation.

Ok, applied.

Thanks.
