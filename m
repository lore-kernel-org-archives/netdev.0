From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_cls: Use __dev_get_by_index()
Date: Thu, 05 Nov 2009 21:08:24 -0800 (PST)
Message-ID: <20091105.210824.233887630.davem@davemloft.net>
References: <4AF1F30B.2030705@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753952AbZKFFH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:58 -0500
In-Reply-To: <4AF1F30B.2030705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 22:32:59 +0100

> We hold RTNL in tc_dump_tfilter(), we can avoid dev_hold()/dev_put()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
