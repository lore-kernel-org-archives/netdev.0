From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2014-09-05
Date: Fri, 05 Sep 2014 22:38:02 -0700 (PDT)
Message-ID: <20140905.223802.2304248161916606656.davem@davemloft.net>
References: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaIFFiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 01:38:03 -0400
In-Reply-To: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 5 Sep 2014 18:02:24 -0500

> The following series of patches includes fixes to the driver.
> 
> - Proper access to 64 bit management counter registers
> - Enable all management counter registers to generate an interrupt when
>   the counter threshold is reached
> 
> This patch series is based on net.

Series applied, thanks Tom.
