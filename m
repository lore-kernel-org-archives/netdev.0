From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: Fixed fragment check in ip6_output.c:ip6_fragment()
Date: Fri, 27 Jun 2003 11:21:43 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306271120580.15380-100000@excalibur.intercode.com.au>
References: <20030626.205540.83592923.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>, <miyazawa@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030626.205540.83592923.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> Hello.
> 
> MTU / alignment check in ip6_fragment() was wrong;
> first_len was not correct.

Applied to bk://kernel.bkbits.net/jmorris/net-2.5


- James
-- 
James Morris
<jmorris@intercode.com.au>
