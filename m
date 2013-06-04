From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: do not manually initialize
 enumerators
Date: Tue, 04 Jun 2013 15:19:16 -0700 (PDT)
Message-ID: <20130604.151916.1956913924827292963.davem@davemloft.net>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
	<1370139797-8912-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab3FDWTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 18:19:17 -0400
In-Reply-To: <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sat,  1 Jun 2013 20:23:16 -0600

> Clean up unnecessary initialization of enumerators as the compiler takes
> care of that.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied.
