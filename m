From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Tons of "BUG: dst overflow ..." messages
Date: Wed, 29 Sep 2004 14:32:16 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929.143216.55773467.yoshfuji@linux-ipv6.org>
References: <415A3635.4070000@pobox.com>
	<20040928214055.609f7715.davem@davemloft.net>
	<415A40D0.7040403@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <415A40D0.7040403@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <415A40D0.7040403@pobox.com> (at Wed, 29 Sep 2004 00:57:52 -0400), Jeff Garzik <jgarzik@pobox.com> says:

> David S. Miller wrote:
> > On Wed, 29 Sep 2004 00:12:37 -0400
> > Jeff Garzik <jgarzik@pobox.com> wrote:
> > 
> > 
> >>BUG: dst underflow 0: cf5dd180 at f8c0be5d
:
> > Can you match up the 0xf8xxxxxx addresses to spots
> > in your System.map?  Thanks.
:
> ipv6 232192 38 - Live 0xf8c01000
> 		       ^^^^  appears to be this

Hmm, I haven't met this (during TAHI test against latest tree).
Would you try latest bk tree?
Plus, if you know how to reproduce this, tell me.

Thank you.

--yoshfuji
