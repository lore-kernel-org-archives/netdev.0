From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: documentation update for IGMP/MLD
 unsolicited report interval knobs
Date: Sun, 11 Aug 2013 21:08:57 -0700 (PDT)
Message-ID: <20130811.210857.2051941705703465307.davem@davemloft.net>
References: <20130812014859.GA13886@order.stressinduktion.org>
	<ku9gvg$27t$1@ger.gmane.org>
	<20130812033358.GA15405@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	william.manley@youview.com, bcrl@kvack.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251Ab3HLEDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 00:03:39 -0400
In-Reply-To: <20130812033358.GA15405@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 12 Aug 2013 05:33:58 +0200

> Joined documentation update for IPv4 and IPv6 MLD/IGMP
> unsolicited_report_interval procfs knobs.
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: William Manley <william.manley@youview.com>
> Cc: Benjamin LaHaise <bcrl@kvack.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Update your ipv6 patch to include these changes, don't make them
seperately.
