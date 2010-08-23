From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: remove duplication type definitions
Date: Sun, 22 Aug 2010 21:14:50 -0700 (PDT)
Message-ID: <20100822.211450.233685201.davem@davemloft.net>
References: <1282531319-13083-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753126Ab0HWEOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:14:33 -0400
In-Reply-To: <1282531319-13083-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 23 Aug 2010 10:41:59 +0800

> __be* are defined in linux/types.h now, and in fact, rds.h isn't exported
> to user space even.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied to net-next-2.6
