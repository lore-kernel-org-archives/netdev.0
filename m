From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: convert /proc/net/igmp6 to seq_file
Date: Tue, 01 Jul 2003 14:37:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.143718.82262791.yoshfuji@linux-ipv6.org>
References: <Mutt.LNX.4.44.0307011439520.26681-100000@excalibur.intercode.com.au>
	<20030701.142947.75158018.yoshfuji@linux-ipv6.org>
	<20030630.222708.48505367.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030630.222708.48505367.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030630.222708.48505367.davem@redhat.com> (at Mon, 30 Jun 2003 22:27:08 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

>    From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
>    Date: Tue, 01 Jul 2003 14:29:47 +0900 (JST)
> 
>    Hmm..., I don't understand why I could compile it...
> 
> CONFIG_SMP=n

Ah,... I understood. :-p

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
