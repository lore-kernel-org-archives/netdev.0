From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 dead in -bk11
Date: Wed, 03 Nov 2004 01:29:23 +0900 (JST)
Message-ID: <20041103.012923.102810732.yoshfuji@linux-ipv6.org>
References: <418781EF.7020100@pobox.com>
	<20041102.225343.06193184.yoshfuji@linux-ipv6.org>
	<4187A4E3.8010600@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org,
        davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <4187A4E3.8010600@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4187A4E3.8010600@pobox.com> (at Tue, 02 Nov 2004 10:16:51 -0500), Jeff Garzik <jgarzik@pobox.com> says:

> > Please send me:
> >  % ifconfig -a
> >  % netstat -nr --inet6
:
> Done, see attached.
> 
> ipv6/working/* is 2.6.10-rc1-bk2, and ipv6/dead/* is 2.6.10-rc1-BK-current.

Okay, thanks.

So... I guess that kernel failed to add "default route" on receipt of RA.
Right?

Hmm..

--yoshfuji
