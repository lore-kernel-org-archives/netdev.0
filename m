From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/5] mlx5 update for 3.18
Date: Fri, 03 Oct 2014 15:42:58 -0700 (PDT)
Message-ID: <20141003.154258.223313563251911246.davem@davemloft.net>
References: <1412241586-10108-1-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: eli@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbaJCWlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:41:00 -0400
In-Reply-To: <1412241586-10108-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>
Date: Thu,  2 Oct 2014 12:19:41 +0300

> This series integrates a new mechanism for populating and extracting field values 
> used in the driver/firmware interaction around command mailboxes.
> 
> Changes from V1:
>  - Remove unused definition of memcpy_cpu_to_be32()
>  - Remove definitions of non_existent_*() and use BUILD_BUG_ON() instead.
>  - Added a patch one line patch to add support for ConnectX-4 devices.
> 
> Changes from V0:
>  - trimmed the auto-generated file to a minimum, as required by the reviewers.

Series applied, thanks Eli.
