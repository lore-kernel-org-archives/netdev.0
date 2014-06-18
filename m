From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/24] net: return actual error on
 register_queue_kobjects
Date: Wed, 18 Jun 2014 16:59:11 -0700 (PDT)
Message-ID: <20140618.165911.2120049330133778152.davem@davemloft.net>
References: <53A0518A.7020300@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff.liu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756554AbaFRX7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:59:12 -0400
In-Reply-To: <53A0518A.7020300@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Liu <jeff.liu@oracle.com>
Date: Tue, 17 Jun 2014 22:32:42 +0800

> From: Jie Liu <jeff.liu@oracle.com>
> 
> Return the actual error code if call kset_create_and_add() failed
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>

Applied, thanks.
