From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: update locking comment
Date: Mon, 14 Mar 2011 15:26:18 -0700 (PDT)
Message-ID: <20110314.152618.241914784.davem@davemloft.net>
References: <1300047106-8545-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	daniel.baluta@gmail.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757361Ab1CNWZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:25:40 -0400
In-Reply-To: <1300047106-8545-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dbaluta@ixiacom.com
Date: Sun, 13 Mar 2011 22:11:46 +0200

> We latch our state using a spinlock not a r/w kind of lock.
> 
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

Applied, thanks.
