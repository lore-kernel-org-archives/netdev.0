From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] ATM: CLIP: C99 initializers
Date: Sun, 6 Jul 2003 03:57:55 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307060357140.22251-100000@excalibur.intercode.com.au>
References: <20030703.183850.78164037.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <chas@cmf.nrl.navy.mil>, <netdev@oss.sgi.com>,
   <linux-atm-general@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030703.183850.78164037.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> This converts nlip_tbl to C99 initializers.
> (and fixes wrong value for proxy_len and locktime.)

Heh, nice catch.

Applied to bk://kernel.bkbits.net/jmorris/net-2.5


- James
-- 
James Morris
<jmorris@intercode.com.au>
