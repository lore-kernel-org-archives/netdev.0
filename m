From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 V2] macvlan fdb replace support
Date: Tue, 23 Jul 2013 16:36:42 -0700 (PDT)
Message-ID: <20130723.163642.1664264574330561708.davem@davemloft.net>
References: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com>
	<1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: tmricht@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933968Ab3GWXgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 19:36:42 -0400
In-Reply-To: <1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Date: Fri, 19 Jul 2013 17:20:08 +0200

> Add support for iproute2 command 'bridge fdb replace ...'.
> The rtnletlink call back function ndo_fdb_add will be called
> with the NLM_F_REPLACE flag set.
> Simply return -EOPNOTSUP.
> 
> Resubmitted because net-next was closed last week.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>

Applied.
