From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers/net: remove some rcu sparse
 warnings
Date: Thu, 27 Jan 2011 14:22:48 -0800 (PST)
Message-ID: <20110127.142248.112602670.davem@davemloft.net>
References: <1296106103.1783.114.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, arnd@arndb.de,
	eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60389
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753137Ab1A0WWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:22:13 -0500
In-Reply-To: <1296106103.1783.114.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Jan 2011 06:28:23 +0100

> Add missing __rcu annotations and helpers.
> minor : Fix some rcu_dereference() calls in macvtap
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
