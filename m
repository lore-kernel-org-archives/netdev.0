From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] cxgb4vf: Fix bug where we were only
 allocating one queue in MSI mode
Date: Tue, 20 Jul 2010 13:23:37 -0700 (PDT)
Message-ID: <20100720.132337.179264545.davem@davemloft.net>
References: <201007200859.30269.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761536Ab0GTUXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:23:20 -0400
In-Reply-To: <201007200859.30269.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Tue, 20 Jul 2010 08:59:30 -0700

>>From 7e141cafe989958267803791aa1bcacfffe5cfb2 Mon Sep 17 00:00:00 2001
> From: Casey Leedom <leedom@chelsio.com>
> Date: Mon, 19 Jul 2010 17:53:48 -0700
> Subject: [PATCH net-next 2/3] cxgb4vf: Fix bug where we were only allocating one queue in MSI mode
> 
> Fix bug in setup_sge_queues() where we were incorrectly only allocating a
> single "Queue Set" for MSI mode.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.
