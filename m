From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 17:58:15 +0900 (JST)
Message-ID: <20050220.175815.50673619.yoshfuji@linux-ipv6.org>
References: <20050220.155527.54695259.yoshfuji@linux-ipv6.org>
	<20050220073719.GA13008@gondor.apana.org.au>
	<42184BC2.1030907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: kaber@trash.net
In-Reply-To: <42184BC2.1030907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <42184BC2.1030907@trash.net> (at Sun, 20 Feb 2005 09:35:14 +0100), Patrick McHardy <kaber@trash.net> says:

> Herbert Xu wrote:
> > So here we can do something like this.  Please note that this patch
> > needs to be used with Patrick's earlier work.  Patrick, if you're
> > OK with it please merge it in with your patch.
> 
> Attached. Now I understand what Yoshifuji meant with byteorder :)

Sorry, still it seems wrong.
Please allow me several hours.

--yoshfuji @ on the way home...
