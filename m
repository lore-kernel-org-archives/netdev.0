From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mcast: Fix source address selection for multicast
 listener report
Date: Wed, 24 Aug 2011 17:46:31 -0700 (PDT)
Message-ID: <20110824.174631.44988400748251543.davem@davemloft.net>
References: <4E54BC4D.8090008@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab1HYAqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:46:34 -0400
In-Reply-To: <4E54BC4D.8090008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Wed, 24 Aug 2011 16:54:37 +0800

> Should check use count of include mode filter instead of total number
> of include mode filters.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied, thank you.
