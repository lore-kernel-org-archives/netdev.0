From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 06 Jul 2012 01:26:00 -0700 (PDT)
Message-ID: <20120706.012600.1789044422848881518.davem@davemloft.net>
References: <1341555227.3265.54.camel@edumazet-glaptop>
	<20120705.234229.526162609862035833.davem@davemloft.net>
	<20120706073745.GA28197@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2GFJTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 05:19:44 -0400
In-Reply-To: <20120706073745.GA28197@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <wfg@linux.intel.com>
Date: Fri, 6 Jul 2012 15:37:45 +0800

> Sorry for that!  Is it fine to _attach_ the referenced patch, or just
> a raw diff?  Or, the commit SHA and subject are all you want to see?

Don't provide the diff at all, in any form.  Even if you attach it
patchwork can still parse it and queued it up.
