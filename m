From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] more statistics updates
Date: Mon, 20 Jun 2011 13:56:07 -0700 (PDT)
Message-ID: <20110620.135607.2158729745388010853.davem@davemloft.net>
References: <20110620203506.363818794@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab1FTU4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:56:09 -0400
In-Reply-To: <20110620203506.363818794@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 20 Jun 2011 13:35:06 -0700

> Fix drivers that are using 64 bit statistics with unsafe access on 32 bit.
> These are compile tested only, because the hardware to test it is not
> easily available.

Where is patch #5?
