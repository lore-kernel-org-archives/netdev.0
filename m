From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: convert /proc/net/igmp6 to seq_file
Date: Tue, 01 Jul 2003 13:23:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.132315.11621908.yoshfuji@linux-ipv6.org>
References: <20030701.015755.80809794.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0307011022430.26034-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0307011022430.26034-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Mutt.LNX.4.44.0307011022430.26034-100000@excalibur.intercode.com.au> (at Tue, 1 Jul 2003 10:23:08 +1000 (EST)), James Morris <jmorris@intercode.com.au> says:

> On Tue, 1 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> 
> > This converts /proc/net/igmp6 to seq_file.
> 
> This does not compile.

Really???? 
I had compiled it before I sent the patch and I can compile it now.
How did you fail to compile it?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
