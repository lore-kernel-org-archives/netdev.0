From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Probe selected algorithm only
Date: Tue, 25 Jan 2005 22:22:18 -0800
Message-ID: <20050125222218.2d516e90.davem@davemloft.net>
References: <20050121101938.GA1133@gondor.apana.org.au>
	<Xine.LNX.4.44.0501210901001.6594-100000@thoron.boston.redhat.com>
	<20050121224546.GA8654@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050121224546.GA8654@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2005 09:45:46 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > > Since we know the type of algorithm required when we're adding a new
> > > SA, we can get away with only probing the selected algorithms.  This
> > > is what the following patch does for xfrm_user.
> > > 
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Looks good to me.
> > 
> > Signed-off-by: James Morris <jmorris@redhat.com>
> 
> Sorry, I forgot to update the calls in af_key.  Here is the corrected
> version.

Applied, thanks Herbert.
