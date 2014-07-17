From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Update setapp/getapp prototypes in
 dcbnl_rtnl_ops to return int instead of u8
Date: Thu, 17 Jul 2014 16:02:45 -0700 (PDT)
Message-ID: <20140717.160245.2071122155827904911.davem@davemloft.net>
References: <1405575159-24136-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	dan.carpenter@oracle.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758140AbaGQXCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:02:45 -0400
In-Reply-To: <1405575159-24136-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 16 Jul 2014 22:32:39 -0700

> v2: fixed issue with checking return of dcbnl_rtnl_ops->getapp()
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
