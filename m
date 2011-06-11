From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] sctp: kzalloc() error handling on deleting last
 address
Date: Sat, 11 Jun 2011 15:54:08 -0700 (PDT)
Message-ID: <20110611.155408.39927768892327095.davem@davemloft.net>
References: <42280E6C-8514-4C01-9B81-35DDE65BBE42@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab1FKWyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 18:54:16 -0400
In-Reply-To: <42280E6C-8514-4C01-9B81-35DDE65BBE42@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Fri, 10 Jun 2011 18:06:15 +0900

>>From be2da529aa45061e77ad96313175e141aaadc16a Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Fri, 10 Jun 2011 16:42:14 +0900
> Subject: [PATCH v1] sctp: kzalloc() error handling on deleting last address
> 
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>

Applied, thanks.
