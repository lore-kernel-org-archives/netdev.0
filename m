From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: use macro for M-Flag and clean-up
Date: Sun, 29 Jun 2003 20:50:08 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306292049170.21415-100000@excalibur.intercode.com.au>
References: <20030629.112544.42878077.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030629.112544.42878077.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> No. We don't use __constant_hton{s,l} in runtime code
> since October, 2002.  We use hton{s,l} when we can.

Ok.

All three patches applied to bk://kernel.bkbits.net/jmorris/net-2.5



- James
-- 
James Morris
<jmorris@intercode.com.au>
