From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx5_core: Set log_uar_page_sz for non 4K
 page size architecture
Date: Fri, 07 Aug 2015 15:56:10 -0700 (PDT)
Message-ID: <20150807.155610.1947602025967878982.davem@davemloft.net>
References: <1438790732-29819-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<55C33E77.2090005@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clsoto@linux.vnet.ibm.com, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com, eli@mellanox.com, majd@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946320AbbHGW4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 18:56:11 -0400
In-Reply-To: <55C33E77.2090005@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 6 Aug 2015 14:01:11 +0300

> On 8/5/2015 7:05 PM, clsoto@linux.vnet.ibm.com wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>> 
>> failed to configure the page size for architectures with page size
>> different than 4K.
>> 
>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
>> ---
> 
> Please pull this patch into kernel 4.2
> 
> Fixes: 938fe83 ("net/mlx5_core: New device capabilities handling")
> Acked-by: Amir Vadai <amirv@mellanox.com>

Applied to 'net', thanks.
