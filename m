From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arp: use assignment
Date: Mon, 06 Dec 2010 13:07:17 -0800 (PST)
Message-ID: <20101206.130717.193709562.davem@davemloft.net>
References: <1291270051-27109-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751425Ab0LFVGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:06:50 -0500
In-Reply-To: <1291270051-27109-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  2 Dec 2010 14:07:31 +0800

> Only when dont_send is 0, arp_filter() is consulted, so we can simply
> assign the return value of arp_filter() to dont_send instead.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
