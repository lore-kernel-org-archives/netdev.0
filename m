From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/4] amd-xgbe: AMD XGBE driver updates
 2014-09-03
Date: Fri, 05 Sep 2014 15:12:30 -0700 (PDT)
Message-ID: <20140905.151230.243427954014414813.davem@davemloft.net>
References: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaIEWMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:12:31 -0400
In-Reply-To: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 3 Sep 2014 12:14:10 -0500

> The following series of patches includes fixes/updates to the driver.
> 
> - Query the device for the actual speed mode (KR/KX) rather than trying
>   to track it
> - Update parallel detection logic to support KR mode
> - Fix new warnings from checkpatch in the amd-xgbe and amd-xgbe-phy
>   driver
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
