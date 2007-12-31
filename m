From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove useless code from fib6_del_route
Date: Sun, 30 Dec 2007 23:27:30 -0800 (PST)
Message-ID: <20071230.232730.138600098.davem@davemloft.net>
References: <4774A1DC.9060308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752778AbXLaH1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 02:27:30 -0500
In-Reply-To: <4774A1DC.9060308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Fri, 28 Dec 2007 15:12:28 +0800

> There are useless codes in fib6_del_route(). The following patch
> has been tested, every thing looks fine, as usual.
> 
> Signed-off-by: Gui Jianfeng<guijianfeng@cn.fujitsu.com>

Patch applied to net-2.6.25, thanks.
