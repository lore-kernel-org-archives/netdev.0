From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: Use PAGE_ALIGNED macro
Date: Thu, 31 Jul 2014 22:05:43 -0700 (PDT)
Message-ID: <20140731.220543.1894373562509830625.davem@davemloft.net>
References: <1406801828-4220-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946AbaHAFFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:05:44 -0400
In-Reply-To: <1406801828-4220-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 31 Jul 2014 12:17:08 +0200

> Use PAGE_ALIGNED(...) instead of IS_ALIGNED(..., PAGE_SIZE).
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
