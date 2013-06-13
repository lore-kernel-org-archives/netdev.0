From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/3] net/core: Add VF link state control
Date: Thu, 13 Jun 2013 02:41:10 -0700 (PDT)
Message-ID: <20130613.024110.843518428947760865.davem@davemloft.net>
References: <1371024728-31790-1-git-send-email-ogerlitz@mellanox.com>
	<1371024728-31790-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758474Ab3FMJlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:41:11 -0400
In-Reply-To: <1371024728-31790-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 12 Jun 2013 11:12:06 +0300

> + * 			 * IFLA_VF_LINK_STATE_AUTO which equals zero 
> + * 			 */

Please get rid of those leading "*" characters.
