From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xps: NUMA allocations for per cpu data
Date: Mon, 29 Nov 2010 09:43:28 -0800 (PST)
Message-ID: <20101129.094328.112605060.davem@davemloft.net>
References: <AANLkTi=8smjJgTXxe7vj8AHAMceLUr25KurZbm07vP1j@mail.gmail.com>
	<1290791866.2855.263.camel@edumazet-laptop>
	<1290959004.29196.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755450Ab0K2RnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 12:43:01 -0500
In-Reply-To: <1290959004.29196.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 28 Nov 2010 16:43:24 +0100

> store_xps_map() allocates maps that are used by single cpu, it makes
> sense to use NUMA allocations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Tom Herbert <therbert@google.com>

Applied.
