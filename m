From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Tue, 29 Apr 2008 19:17:54 -0700 (PDT)
Message-ID: <20080429.191754.29710117.davem@davemloft.net>
References: <1209435597.2624.35.camel@debian.sh.intel.com>
	<20080429132720.GB4887@tuxdriver.com>
	<1209521679.2827.23.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jason@acm.org, netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754137AbYD3CR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 22:17:56 -0400
In-Reply-To: <1209521679.2827.23.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Wed, 30 Apr 2008 10:14:39 +0800

> I just realized the kernel now updates vmlinux when I type 'make' even
> if nothing is changed in the source code. Is this a bug or feature?

The build number increments every time you make.

That's where the "#nn" in the uname output comes from.
