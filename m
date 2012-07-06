From: Fengguang Wu <wfg@linux.intel.com>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 6 Jul 2012 15:37:45 +0800
Message-ID: <20120706073745.GA28197@localhost>
References: <20120705.142200.1828988382587831318.davem@davemloft.net>
 <20120706055859.GA27693@localhost>
 <1341555227.3265.54.camel@edumazet-glaptop>
 <20120705.234229.526162609862035833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7185 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003Ab2GFHhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 03:37:48 -0400
Content-Disposition: inline
In-Reply-To: <20120705.234229.526162609862035833.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> Fengguang Wu can I ask you politely not to quote the quilty patch in
> it's entirety when reporting bugs?  That screws up my workflow because
> that patch goes then gets installed as a new patch in patchwork and I
> have to therefore tick it off every time you report a bug.

Sorry for that!  Is it fine to _attach_ the referenced patch, or just
a raw diff?  Or, the commit SHA and subject are all you want to see?

Thanks,
Fengguang
