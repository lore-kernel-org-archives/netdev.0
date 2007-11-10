From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 23:48:54 +0900 (JST)
Message-ID: <20071110.234854.10674315.yoshfuji@linux-ipv6.org>
References: <20071110131428.GA6447@gondor.apana.org.au>
	<20071110.223243.114494952.yoshfuji@linux-ipv6.org>
	<20071110143325.GA6888@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39807 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbXKJOsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 09:48:47 -0500
In-Reply-To: <20071110143325.GA6888@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071110143325.GA6888@gondor.apana.org.au> (at Sat, 10 Nov 2007 22:33:25 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Sat, Nov 10, 2007 at 10:32:43PM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> >
> > Hmm?  netstat 1.42 (net-tools 1.60) seems fine.
> > Which netstat are you using?
> 
> The one from Debian etch:

Hmm..... "netstat -s" from etch (i386) and etch (x86_64) work
fine for me.  Same version, same architecture.  Strange...

--yoshfuji
