From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 22:42:09 +1100
Message-ID: <20041110114209.GA11336@gondor.apana.org.au>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <20041110014125.GA7302@gondor.apana.org.au> <20041110113236.GM31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20041110113236.GM31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 10, 2004 at 12:32:36PM +0100, Thomas Graf wrote:
> 
> Agreed. I'm used to huge filter configurations up to 100 MiB per
> netlink message and therefore I do care whether such as message is

100MiB!? How did you manage to stuff that into one linear skb?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
