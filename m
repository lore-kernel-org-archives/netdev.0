From: "David S. Miller" <davem@davemloft.net>
Subject: Re: network manpages was Re: is UDP_CORK "real"
Date: Wed, 27 Apr 2005 11:43:23 -0700
Message-ID: <20050427114323.53e43e32.davem@davemloft.net>
References: <426833F0.9010803@hp.com>
	<m1u0lty7uh.fsf@muc.de>
	<426F2A1D.10001@aarnet.edu.au>
	<20050427122648.GA12597@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: glen.turner@aarnet.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050427122648.GA12597@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27 Apr 2005 14:26:48 +0200
Andi Kleen <ak@muc.de> wrote:

> It would be nice of course if David could enforce a policy
> to require a manpage patch for new ioctls/socket options etc.
> in the future, then such documentation lag would not happen.

I could easily do this if the files were in the kernel tree
itself, but since it's external it's not so easy to do.

Why don't we put them into the kernel tree?  They are just
small documents and I bet they will stay in sync better if
they were moved into the kernel tree.
