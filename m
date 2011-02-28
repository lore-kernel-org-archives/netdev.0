From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: avoid skb_clone() if there is only one handler
Date: Mon, 28 Feb 2011 12:29:02 -0800 (PST)
Message-ID: <20110228.122902.260082804.davem@davemloft.net>
References: <1298375718-5052-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752955Ab1B1U2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:28:25 -0500
In-Reply-To: <1298375718-5052-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 22 Feb 2011 19:55:18 +0800

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied to net-next-2.6, thanks.
