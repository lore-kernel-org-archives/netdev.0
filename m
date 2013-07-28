From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4,ipv6: send igmpv3/mld packets with
 TC_PRIO_CONTROL
Date: Sun, 28 Jul 2013 11:14:25 -0700 (PDT)
Message-ID: <20130728.111425.193287704194198703.davem@davemloft.net>
References: <20130726150516.GC3890@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org, william.manley@youview.com,
	luky-37@hotmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912Ab3G1SO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 14:14:26 -0400
In-Reply-To: <20130726150516.GC3890@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 26 Jul 2013 17:05:16 +0200

> v2:
> a) Also send ipv4 igmp messages with TC_PRIO_CONTROL
> 
> Cc: William Manley <william.manley@youview.com>
> Cc: Lukas Tribus <luky-37@hotmail.com>
> Acked-by: Benjamin LaHaise <bcrl@kvack.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
