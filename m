From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] NET: fix SEGV/OOPS with /proc/net/{raw,igmp,...} (is
 Re: [Bug 863] New: cat /proc/buddyinfo + netstat -a kills machine)
Date: Thu, 3 Jul 2003 20:13:51 +1000 (EST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Mutt.LNX.4.44.0307032013200.14369-100000@excalibur.intercode.com.au>
References: <20030703.154429.06241047.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <acme@conectiva.com.br>,
	<linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
	<mbligh@aracnet.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20030703.154429.06241047.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

On Thu, 3 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> I'm not so sure if this is ralated to BUG#863, but anyway;
> 
> Following patch fixes segv/oops with /proc/net/{raw,igmp,mfilter,
> raw6,igmp6,mfilter6,anycast,ip6_flowlabel}.

Applied to bk://kernel.bkbits.net/jmorris/net-2.5

- James
-- 
James Morris
<jmorris@intercode.com.au>
