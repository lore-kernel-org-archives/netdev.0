From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV4: convert /proc/net/mcfilter to seq_file
Date: Tue, 1 Jul 2003 14:43:30 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307011441410.26681-100000@excalibur.intercode.com.au>
References: <20030701.131552.10422805.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030701.131552.10422805.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> What do you mean by "previous patches?"

The group of patches which started with
Subject: [PATCH] IPV6: convert /proc/net/igmp6 to seq_file

> /proc/net/mcfilter patch depends on /proc/net/igmp patch 
> as I wrote.

Yes, and the /proc/net/igmp patch does not compile for me, and I cannot 
thus apply and test it.


- James
-- 
James Morris
<jmorris@intercode.com.au>
