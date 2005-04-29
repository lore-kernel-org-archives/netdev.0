From: Andi Kleen <ak@muc.de>
Subject: Re: network manpages was Re: is UDP_CORK "real"
Date: 29 Apr 2005 17:29:39 +0200
Message-ID: <20050429152939.GB38331@muc.de>
References: <426833F0.9010803@hp.com> <m1u0lty7uh.fsf@muc.de> <426F2A1D.10001@aarnet.edu.au> <20050427122648.GA12597@muc.de> <20050427114323.53e43e32.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: glen.turner@aarnet.edu.au, netdev@oss.sgi.com, mtk-lkml@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
Date: Fri, 29 Apr 2005 17:29:39 +0200
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050427114323.53e43e32.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 11:43:23AM -0700, David S. Miller wrote:
> On 27 Apr 2005 14:26:48 +0200
> Andi Kleen <ak@muc.de> wrote:
> 
> > It would be nice of course if David could enforce a policy
> > to require a manpage patch for new ioctls/socket options etc.
> > in the future, then such documentation lag would not happen.
> 
> I could easily do this if the files were in the kernel tree
> itself, but since it's external it's not so easy to do.

Hmm, you could ask them at least to submit a patch.

> 
> Why don't we put them into the kernel tree?  They are just
> small documents and I bet they will stay in sync better if
> they were moved into the kernel tree.

Well, you have to talk to Michael who maintains them now.
I personally think it would be a good idea, yes.

-Andi
