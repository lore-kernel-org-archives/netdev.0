From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV4: convert /proc/net/mcfilter to seq_file
Date: Tue, 1 Jul 2003 10:29:37 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307011025480.26034-100000@excalibur.intercode.com.au>
References: <20030701.015752.117028166.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030701.015752.117028166.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> Hello.
> 
> This patch, depends on "[PATCH] IPV4: convert /proc/net/igmp to 
> seq_file patch," converts /proc/net/mcfilter to seq_file.

None of these either compile or applies cleanly without the previous 
patches.


- James
-- 
James Morris
<jmorris@intercode.com.au>
