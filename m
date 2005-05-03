From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Tue, 3 May 2005 16:10:34 -0700
Message-ID: <20050503161034.1fc3ec38.davem@davemloft.net>
References: <4276B13F.2040103@tpack.net>
	<20050503100306.GB29788@gondor.apana.org.au>
	<4277FC16.4050307@tpack.net>
	<20050503231023.GA18323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503231023.GA18323@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 May 2005 09:10:23 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 04, 2005 at 12:32:54AM +0200, Tommy Christensen wrote:
> > 
> > Anyway, given the comments from Thomas, I've pulled out the IFF_RUNNING
> > stuff. We can add this later, when the other uses have been sorted out.
> 
> Thanks Tommy.  This version looks good to me.  BTW, you probably
> should add a Signed-off-by line.

Yes, please provide this and I'll happily apply this patch.
Thanks.
