From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Add missing newline for skb_*_panic
Date: Thu, 21 Apr 2005 16:44:18 -0700
Message-ID: <20050421164418.34cc81a2.davem@davemloft.net>
References: <20050421050815.GA23133@gondor.apana.org.au>
	<42682527.3000709@trash.net>
	<42682718.3060601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42682718.3060601@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 00:20:08 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > How about this one instead? Besides the missing newlines, it adds
> > head/data/tail/end to the output, which can give valuable hints
> > about what happend before.
> 
> While we're at it, lets also replace KERN_INFO by KERN_EMERG to
> make sure the user gets to see it.
> 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
