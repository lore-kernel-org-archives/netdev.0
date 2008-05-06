From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make IWLWIFI a tristate
Date: Tue, 06 May 2008 00:05:01 -0700 (PDT)
Message-ID: <20080506.000501.157638323.davem@davemloft.net>
References: <1209435597.2624.35.camel@debian.sh.intel.com>
	<20080505182516.GM17139@cs181133002.pp.htv.fi>
	<1210037178.2827.152.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, jason@acm.org, netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752639AbYEFHFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 03:05:03 -0400
In-Reply-To: <1210037178.2827.152.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Tue, 06 May 2008 09:26:18 +0800

> On Mon, 2008-05-05 at 21:25 +0300, Adrian Bunk wrote:
> > @@ -1,6 +1,5 @@
> >  config IWLWIFI
> > -       bool
> > -       default n
> > +       tristate
> >  
> >  config IWLCORE
> >         tristate "Intel Wireless Wifi Core"
> 
> Great. Thank you Adrian!

I've applied Adrian's patch, thanks everyone.
