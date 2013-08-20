From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] enic: This patchset adds support for Cisco Low
 Latency NIC
Date: Tue, 20 Aug 2013 13:41:21 -0700 (PDT)
Message-ID: <20130820.134121.930359746938638679.davem@davemloft.net>
References: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, umalhi@cisco.com, nistrive@cisco.com,
	benve@cisco.com
To: neepatel@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3HTUlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:41:22 -0400
In-Reply-To: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>
Date: Fri, 16 Aug 2013 15:47:38 -0700

> v1 -> v2:  
>     - Removed OOM messages 
>     - Removed ethtool patch where, enic was storing ASIC info in a reserved 
>         field of ethtool_drvinfo structure 
>  
> v2 -> v3: 
>     - Removed unused functions for descriptor prefetch, because, this feature is  
>         not enabled yet.
> 
> Signed-off-by: Neel Patel <neepatel@cisco.com>
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Applied to net-next, thanks.
