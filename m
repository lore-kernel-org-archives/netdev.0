From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] enic: update to support 64 bit stats
Date: Wed, 08 Jun 2011 23:27:09 -0700 (PDT)
Message-ID: <20110608.232709.974346733826374887.davem@davemloft.net>
References: <20110609005356.160260858@vyatta.com>
	<20110609005417.630728228@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, vkolluri@cisco.com, roprabhu@cisco.com,
	dwang2@cisco.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab1FIG1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:27:11 -0400
In-Reply-To: <20110609005417.630728228@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 08 Jun 2011 17:54:02 -0700

> The device driver already uses 64 bit statistics, it just
> doesn't use the 64 bit interface.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
