From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 1/2] tipc: refactor name table updates out
 of named packet receive routine
Date: Mon, 01 Sep 2014 17:52:18 -0700 (PDT)
Message-ID: <20140901.175218.1469855151906643305.davem@davemloft.net>
References: <1409209727-15265-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbaIBAwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 20:52:22 -0400
In-Reply-To: <1409209727-15265-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 28 Aug 2014 09:08:46 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> We need to perform the same actions when processing deferred name
> table updates, so this functionality is moved to a separate
> function.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Applied.
