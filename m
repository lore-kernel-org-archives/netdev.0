From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] veth: convert to 64 bit statistics
Date: Wed, 08 Jun 2011 23:26:56 -0700 (PDT)
Message-ID: <20110608.232656.141076976417707897.davem@davemloft.net>
References: <20110609005356.160260858@vyatta.com>
	<20110609005417.449670103@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198Ab1FIG06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:26:58 -0400
In-Reply-To: <20110609005417.449670103@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 08 Jun 2011 17:53:59 -0700

> Not much change, device was already keeping per cpu statistics.
> Use recent 64 statistics interface.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
