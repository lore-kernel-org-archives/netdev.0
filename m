From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 16:09:22 -0700 (PDT)
Message-ID: <20120627.160922.686783180082355740.davem@davemloft.net>
References: <4FEB7BB9.1080905@candelatech.com>
	<1340832947.26242.169.camel@edumazet-glaptop>
	<4FEB90C3.9050607@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	shemminger@vyatta.com, tparkin@katalix.com, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jchapman@katalix.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757393Ab2F0XJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 19:09:25 -0400
In-Reply-To: <4FEB90C3.9050607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 27 Jun 2012 16:01:23 -0700

> At 100 Gbit/s Ethernet, that is upwards of 147

Listing upcoming technologies shows that you miss Eric's point.

Nobody with a brain is going to drive those kinds of cards on boxes
running 32-bit kernels.
