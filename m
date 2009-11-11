From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] parisc: led: Use for_each_netdev_rcu()
Date: Tue, 10 Nov 2009 22:35:14 -0800 (PST)
Message-ID: <20091110.223514.06086094.davem@davemloft.net>
References: <4AF8E700.9080307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172AbZKKGer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:34:47 -0500
In-Reply-To: <4AF8E700.9080307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Nov 2009 05:07:28 +0100

> Use for_each_netdev_rcu() and dont lock dev_base_lock anymore
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
