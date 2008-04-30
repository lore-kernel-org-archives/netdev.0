From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Wed, 30 Apr 2008 10:31:07 +0800
Message-ID: <1209522667.2827.26.camel@debian.sh.intel.com>
References: <1209435597.2624.35.camel@debian.sh.intel.com>
	 <20080429132720.GB4887@tuxdriver.com>
	 <1209521679.2827.23.camel@debian.sh.intel.com>
	 <20080429.191754.29710117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jason@acm.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4458 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbYD3CcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 22:32:01 -0400
In-Reply-To: <20080429.191754.29710117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-29 at 19:17 -0700, David Miller wrote:
> The build number increments every time you make.
> 
> That's where the "#nn" in the uname output comes from.

Well, if nothing is changed, why it tries to recompile the image? IIRC,
we don't have this problem in early kernels.

Thanks,
-yi

