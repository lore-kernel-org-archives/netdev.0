From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: Known problems with TCP window size on 2.6.7?
Date: Thu, 28 Oct 2004 01:19:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027231907.GA9093@vana.vc.cvut.cz>
References: <20041027110617.GA28757@vana.vc.cvut.cz> <E1CMml4-0001Cm-00@gondolin.me.apana.org.au> <20041027145356.6c22959e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041027145356.6c22959e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 02:53:56PM -0700, David S. Miller wrote:
> On Wed, 27 Oct 2004 22:18:30 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> > >   are there some known problems with 2.6.7 and TCP window growing up over limits?  
> > 
> > No.
> 
> Actually Herbert, we did have a window 16-bit overflow problem in 2.6.7
> which I believe was first fixed in 2.6.8 or so.  It was fixed by this
> patch:

Thanks a lot.  Time to upgrade, then.
								Petr
