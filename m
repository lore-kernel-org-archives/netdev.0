From: James Morris <jmorris@intercode.com.au>
Subject: Re: Bug in Linux 2.5.74 IPv6 routing
Date: Thu, 10 Jul 2003 11:30:55 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307101130460.15193-100000@excalibur.intercode.com.au>
References: <20030710.034425.55677522.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <Jean-Luc.Richier@imag.fr>, <pekkas@netcore.fi>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030710.034425.55677522.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> Please apply this patch.
> 
> D: Fix ipv6_addr_prefix() for prefixlen != 0 (mod 8).
> D: Patch from Jean-Luc RICHIER <Jean-Luc.Richier@Imag.Fr>.

Applied to bk://kernel.bkbits.net/jmorris/net-2.5


-- 
James Morris
<jmorris@intercode.com.au>
