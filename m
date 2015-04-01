From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] chelsio cxgb/cxgb3: Make stats_strings arrays
 const
Date: Wed, 01 Apr 2015 14:41:32 -0400 (EDT)
Message-ID: <20150401.144132.2127701773797242867.davem@davemloft.net>
References: <1427892333-26330-1-git-send-email-hariprasad@chelsio.com>
	<1427874122.31790.8.camel@perches.com>
	<1427903364.31790.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, santosh@chelsio.com,
	netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com, varun@chelsio.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbbDASlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:41:35 -0400
In-Reply-To: <1427903364.31790.14.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 01 Apr 2015 08:49:24 -0700

> Move ~2KB of strings in each driver from data to text.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Here a patch for the other 2 drivers

Applied, thanks Joe.
