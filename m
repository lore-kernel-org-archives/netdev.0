From: "David S. Miller" <davem@redhat.com>
Subject: Re: [UDP] Move common code out in udp_encap_rcv
Date: Sat, 26 Jun 2004 11:39:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626113938.34d4d6cc.davem@redhat.com>
References: <20040626064427.GA25395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040626064427.GA25395@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Jun 2004 16:44:27 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch simply moves the common code out of the switch statement
> in udp_encap_rcv().

Nice cleanup, applied.
