From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NET: disconnect support by null address (is Re:
 Disconnecting a connected UDP socket)
Date: Fri, 04 Jul 2003 02:48:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030704.024850.88858438.yoshfuji@linux-ipv6.org>
References: <20030703031610.79050.qmail@web20704.mail.yahoo.com>
	<20030704.022857.07343571.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shibu_lkml@yahoo.com, davem@redhat.com, jmorris@intercode.com.au
In-Reply-To: <20030704.022857.07343571.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030704.022857.07343571.yoshfuji@linux-ipv6.org> (at Fri, 04 Jul 2003 02:28:57 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> It seems.  Please apply this.

Sorry, I was too hurry.
net/ipv4/af_inet.c:inet_dgram_connect() cares this case.
Please forget the patch...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
