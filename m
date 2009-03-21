From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management
Date: Sat, 21 Mar 2009 13:40:12 -0700 (PDT)
Message-ID: <20090321.134012.219109226.davem@davemloft.net>
References: <Pine.WNT.4.64.0903200019240.14460@ppwaskie-MOBL2.amr.corp.intel.com>
	<20090320092434.7ac1baf3@nehalam>
	<Pine.WNT.4.64.0903201013300.16596@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754101AbZCUUkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:40:25 -0400
In-Reply-To: <Pine.WNT.4.64.0903201013300.16596@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 20 Mar 2009 10:14:38 -0700 (Pacific Daylight Time)

> On Fri, 20 Mar 2009, Stephen Hemminger wrote:
> 
> > On Fri, 20 Mar 2009 00:23:39 -0700 (Pacific Daylight Time)
> > "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:
> > 
> > > On Thu, 19 Mar 2009, Stephen Hemminger wrote:
> > > 
> > > > Convert ixgbe to use net_device_ops properly.
> > > > Rather than changing the select_queue function pointer
> > > > just check the flag.
> > > > 
> > > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
...
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
