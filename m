From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Use add_timer instead of mod_timer in find_acq
Date: Mon, 24 May 2004 10:15:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524101545.579b79b2.davem@redhat.com>
References: <20040524115357.GA28827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040524115357.GA28827@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 May 2004 21:53:57 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a tiny optimisation to use add_timer instead of mod_timer
> on the create path in find_acq.

Applied, thanks.
