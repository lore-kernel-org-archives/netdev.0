From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: Fix large packet length check
Date: Tue, 24 Jun 2003 18:47:26 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306241846150.5688-100000@excalibur.intercode.com.au>
References: <20030624.124030.123761150.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030624.124030.123761150.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> This patch fixes the problem.
> Patch against [PATCH] IPV6: use macro for maximum payload length patch.

I've applied both of these to bk://kernel.bkbits.net/jmorris/net-2.5


- James
-- 
James Morris
<jmorris@intercode.com.au>
