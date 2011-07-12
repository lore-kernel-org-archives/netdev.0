From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: remove e1000_queue_stats
Date: Mon, 11 Jul 2011 20:10:02 -0700 (PDT)
Message-ID: <20110711.201002.976790708464831126.davem@davemloft.net>
References: <1310414440.2860.9.camel@edumazet-laptop>
	<E0862362F1FF584BBCF7C4EA592A20C40755D948@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab1GLDKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:10:06 -0400
In-Reply-To: <E0862362F1FF584BBCF7C4EA592A20C40755D948@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Mon, 11 Jul 2011 13:18:54 -0700

>>struct e1000_queue_stats is not used, lets remove it
>>
>>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Nothing further needed.
> 
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>

Applied.
