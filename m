From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: fix panic on load
Date: Sun, 31 Oct 2010 09:34:10 -0700 (PDT)
Message-ID: <20101031.093410.226763732.davem@davemloft.net>
References: <1288540238.2660.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756185Ab0JaQdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 12:33:46 -0400
In-Reply-To: <1288540238.2660.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 31 Oct 2010 16:50:38 +0100

> Its now illegal to call netif_stop_queue() before register_netdev()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
