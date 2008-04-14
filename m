From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [IPV6] MIP6: Ensure independence from
 alignment.
Date: Sun, 13 Apr 2008 23:34:03 -0700 (PDT)
Message-ID: <20080413.233403.150378172.davem@davemloft.net>
References: <20080413.222629.180789339.davem@davemloft.net>
	<20080414.143832.10983998.yoshfuji@wide.ad.jp>
	<20080414.152245.45102039.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752750AbYDNGeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:34:02 -0400
In-Reply-To: <20080414.152245.45102039.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Apr 2008 15:22:45 +0900 (JST)

> In article <20080414.143832.10983998.yoshfuji@wide.ad.jp> (at Mon, 14 Apr 2008 14:38:32 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp> says:
> 
> > > Please just mark the structure with "packed" attribute.
> > 
> > Sure!
> 
> Here it is:

Applied to net-2.6, thank you.
