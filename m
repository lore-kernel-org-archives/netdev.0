From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: static functions
Date: Mon, 19 Apr 2010 14:41:07 -0700 (PDT)
Message-ID: <20100419.144107.182601347.davem@davemloft.net>
References: <1271712395.3845.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751581Ab0DSVlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 17:41:02 -0400
In-Reply-To: <1271712395.3845.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Apr 2010 23:26:35 +0200

> store_rps_map() & store_rps_dev_flow_table_cnt() are static.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
