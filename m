From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV4: convert /proc/net/mcfilter to seq_file
Date: Tue, 01 Jul 2003 13:15:52 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.131552.10422805.yoshfuji@linux-ipv6.org>
References: <20030701.015752.117028166.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0307011025480.26034-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0307011025480.26034-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Mutt.LNX.4.44.0307011025480.26034-100000@excalibur.intercode.com.au> (at Tue, 1 Jul 2003 10:29:37 +1000 (EST)), James Morris <jmorris@intercode.com.au> says:

> > This patch, depends on "[PATCH] IPV4: convert /proc/net/igmp to 
> > seq_file patch," converts /proc/net/mcfilter to seq_file.
> 
> None of these either compile or applies cleanly without the previous 
> patches.

What do you mean by "previous patches?"

/proc/net/mcfilter patch depends on /proc/net/igmp patch 
as I wrote.

Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
