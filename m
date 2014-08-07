From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Fix duplicate #include headers
Date: Thu, 07 Aug 2014 16:04:33 -0700 (PDT)
Message-ID: <20140807.160433.517203433717468732.davem@davemloft.net>
References: <1407415846-10277-3-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbaHGXEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:04:34 -0400
In-Reply-To: <1407415846-10277-3-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Thu,  7 Aug 2014 06:50:45 -0600

> This series fixes duplicate #include headers in the current net
> tree.
> 
> Jean Sacren (3):
>   amd: xgbe: delete duplicate linux/phy.h header
>   batman: delete duplicate multicast.h header
>   openvswitch: fix duplicate #include headers

Series applied.
