From: "David S. Miller" <davem@redhat.com>
Subject: Re: [INET] Update ECN handling wrt RFC 3168
Date: Wed, 8 Sep 2004 13:53:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908135328.4431919a.davem@redhat.com>
References: <20040908031102.GA9273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040908031102.GA9273@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Sep 2004 13:11:02 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch brings the IP ECN handling up-to-date with repsect to
> RFC 3168.  Mostly this means treating ECT(1) in the same way as
> ECT(0).

Looks great, patch applied.
