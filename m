From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Tue, 29 Apr 2008 19:32:53 -0700 (PDT)
Message-ID: <20080429.193253.188598222.davem@davemloft.net>
References: <1209521679.2827.23.camel@debian.sh.intel.com>
	<20080429.191754.29710117.davem@davemloft.net>
	<1209522667.2827.26.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jason@acm.org, netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754298AbYD3Ccz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 22:32:55 -0400
In-Reply-To: <1209522667.2827.26.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Wed, 30 Apr 2008 10:31:07 +0800

> On Tue, 2008-04-29 at 19:17 -0700, David Miller wrote:
> > The build number increments every time you make.
> > 
> > That's where the "#nn" in the uname output comes from.
> 
> Well, if nothing is changed, why it tries to recompile the image? IIRC,
> we don't have this problem in early kernels.

Something did change, the build number in the header file.
