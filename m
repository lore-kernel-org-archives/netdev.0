From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] [IPV6] clean-up advmss calculation (fwd)
Date: Mon, 23 Jun 2003 20:26:40 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306232011440.2333-100000@excalibur.intercode.com.au>
References: <Mutt.LNX.4.44.0306230150330.578-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28B?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <Mutt.LNX.4.44.0306230150330.578-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Jun 2003, James Morris wrote:

> This patch introduces ipv6_advmss() and clean-up advmss calculation.
> Thanks.

I've applied this to a bk tree at:
bk://kernel.bkbits.net/jmorris/net-2.5

I'll be trialling collecting some of the networking patches here so that
Dave can pull them into his tree, instead of having to apply every single
patch which is posted.


- James
-- 
James Morris
<jmorris@intercode.com.au>
