From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6.22 TAKE 2] [IPV6] FIB6RULE: Find source address
 during looking up route.
Date: Fri, 06 Apr 2007 16:53:13 +0900 (JST)
Message-ID: <20070406.165313.96529522.yoshfuji@linux-ipv6.org>
References: <20070328.130808.21341937.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, takamiya@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40601 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbXDFHwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 03:52:20 -0400
In-Reply-To: <20070328.130808.21341937.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070328.130808.21341937.yoshfuji@linux-ipv6.org> (at Wed, 28 Mar 2007 13:08:08 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> When looking up route for destination with rules with
> source address restrictions, we may need to find a source
> address for the traffic if not given.
> 
> Based on patch from Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Dave? How about this?

--yoshfuji
