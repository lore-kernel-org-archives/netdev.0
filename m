From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] sch_sfq: add sanity check for the packet length
Date: Wed, 04 Aug 2010 21:55:59 -0700 (PDT)
Message-ID: <20100804.215559.27816462.davem@davemloft.net>
References: <1280933939-17548-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757280Ab0HEEzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 00:55:40 -0400
In-Reply-To: <1280933939-17548-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  4 Aug 2010 22:58:59 +0800

> The packet length should be checked before the packet data is dereferenced.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
