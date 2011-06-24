From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 hitting route max_size
Date: Fri, 24 Jun 2011 14:35:20 -0700 (PDT)
Message-ID: <20110624.143520.25597812164428056.davem@davemloft.net>
References: <20110606231521.GB22559@hostway.ca>
	<20110607.005645.1883989402770213985.davem@davemloft.net>
	<20110609044042.GA32537@hostway.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: sim@hostway.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701Ab1FXVg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 17:36:26 -0400
In-Reply-To: <20110609044042.GA32537@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kirby <sim@hostway.ca>
Date: Wed, 8 Jun 2011 21:40:42 -0700

> Didn't apply to 2.6.39, so I tried 3.0-rc2, but I get an Oops when
> running the example reproduction case I gave before (

I'll try to debug this.
