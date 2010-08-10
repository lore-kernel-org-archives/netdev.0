From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make netpoll_rx return bool for !CONFIG_NETPOLL
Date: Tue, 10 Aug 2010 16:24:50 -0700 (PDT)
Message-ID: <20100810.162450.191383391.davem@davemloft.net>
References: <1281469487-8946-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758133Ab0HJXYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:24:31 -0400
In-Reply-To: <1281469487-8946-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 10 Aug 2010 15:44:47 -0400

> "netpoll: Use 'bool' for netpoll_rx() return type." missed the case when
> CONFIG_NETPOLL is disabled.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied, thanks John.
