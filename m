From: Anton Blanchard <anton@samba.org>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 01:55:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921155516.GY2825@krispykreme>
References: <20040920063012.GL2825@krispykreme> <414EFD2A.5000805@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <414EFD2A.5000805@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Niv,

> Hey Anton,  yep, I was just debugging this. TSO mainline reworked
> implementation is still not cooked. Don't worry, final state won't
> be this bad :).

Cool :)

> Could you echo 0 > /proc/sys/net/ipv4/tcp_bic and redo test,
> please?

It didnt seem to help.

Anton
