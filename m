From: "David S. Miller" <davem@redhat.com>
Subject: Re: [XFRM] Add FLUSHSA and FLUSHPOLICY
Date: Fri, 9 Jul 2004 16:59:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709165943.32c396ff.davem@redhat.com>
References: <20040709101327.GA12291@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040709101327.GA12291@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jul 2004 20:13:27 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds FLUSHSA and FLUSHPOLICY to xfrm_user which are
> analagous to SADB_FLUSH and SADB_X_SPDFLUSH in af_key.
> 
> This is useful in KMs on startup/shutdown so that the system is
> reset to a known state.

Looks good.  Applied, thanks Herbert.
