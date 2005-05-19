From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 19 May 2005 16:16:09 -0700 (PDT)
Message-ID: <20050519.161609.00748235.davem@davemloft.net>
References: <20050519.130859.115641546.davem@davemloft.net>
	<20050519213839.GC24024@gondor.apana.org.au>
	<428D1E19.9030204@tpack.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, chamas@h4.dion.ne.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net
In-Reply-To: <428D1E19.9030204@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Fri, 20 May 2005 01:15:37 +0200

> Herbert Xu wrote:
> > On Thu, May 19, 2005 at 01:08:59PM -0700, David S. Miller wrote:
> > 
> >>Ok, I think I got all the patches straight.  All of Tommy's
> >>patches combined together look like this diff in my tree.
> >>Please double check it.
> > 
> > Yes this is the one.
> 
> Yup. This combination fixes both problems.

Thanks a lot for double checking, both of you :-)
