From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Fri, 14 Jan 2005 14:10:51 +0900 (JST)
Message-ID: <20050114.141051.80900279.yoshfuji@linux-ipv6.org>
References: <20050112132126.GI26856@postel.suug.ch>
	<20050112.223600.09187852.yoshfuji@linux-ipv6.org>
	<20050113205407.13154ccd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050113205407.13154ccd.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050113205407.13154ccd.davem@davemloft.net> (at Thu, 13 Jan 2005 20:54:07 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Wed, 12 Jan 2005 22:36:00 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > David, I think we need to fix sit.c, anyway.
> > 
> > Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> Good catch, I will apply this patch.

Please apply against 2.4.x as well.
Thanks.

--yoshfuji
