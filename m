From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ESP4] Merge NAT-T code in esp_output
Date: Mon, 5 Jul 2004 15:59:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705155927.04ffb674.davem@redhat.com>
References: <20040701123344.GA11639@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040701123344.GA11639@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Jul 2004 22:33:44 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> This is another step on the way to distilling the tunnel mode encap
> code between AH/ESP/IPCOMP.
> 
> This patch removes the needless duplciation of NAT-T code between
> transport mode and tunnel mode ESP4.

Looks good, applied.
