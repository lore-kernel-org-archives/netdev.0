From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 12:46:34 -0800
Message-ID: <20050125124634.4b749ca9.davem@davemloft.net>
References: <20050124005348.GL23931@postel.suug.ch>
	<E1Cst4o-0007bD-00@gondolin.me.apana.org.au>
	<20050123202715.281ac87c.davem@davemloft.net>
	<20050124121610.GP23931@postel.suug.ch>
	<41F50B6C.6010107@davidcoulson.net>
	<20050124151510.GV23931@postel.suug.ch>
	<20050124225423.GA15405@gondor.apana.org.au>
	<20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
	<20050124164049.3b939791.davem@davemloft.net>
	<20050125112346.GA20704@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, david@davidcoulson.net, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050125112346.GA20704@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 22:23:46 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Jan 24, 2005 at 04:40:49PM -0800, David S. Miller wrote:
> > 
> > Good catch Herbert, I'll integrate this fix.  2.4.x needs it too
> > I'm pretty sure.
> 
> Well I just had a look there and no, this clever frag reuse code
> was added in 2.5.

Right, I noticed this too when I tried to "backport" the 2.6.x
patch :-)
