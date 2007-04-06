From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.22 TAKE 2] [IPV6] FIB6RULE: Find source address
 during looking up route.
Date: Fri, 06 Apr 2007 11:46:11 -0700 (PDT)
Message-ID: <20070406.114611.131105897.davem@davemloft.net>
References: <20070328.130808.21341937.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752893AbXDFSqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 14:46:12 -0400
In-Reply-To: <20070328.130808.21341937.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 28 Mar 2007 13:08:08 +0900 (JST)

> When looking up route for destination with rules with
> source address restrictions, we may need to find a source
> address for the traffic if not given.
> 
> Based on patch from Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thanks a lot.
