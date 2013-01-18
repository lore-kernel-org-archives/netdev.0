From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ndisc: Check NS message length before access.
Date: Fri, 18 Jan 2013 14:42:00 -0500 (EST)
Message-ID: <20130118.144200.224203094224689761.davem@davemloft.net>
References: <50F93A6F.9020303@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab3ARTmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:42:03 -0500
In-Reply-To: <50F93A6F.9020303@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 18 Jan 2013 21:05:03 +0900

> Check message length before accessing "target" field,
> as we do for other types.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
