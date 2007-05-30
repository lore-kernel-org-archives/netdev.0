From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 15:29:39 -0700 (PDT)
Message-ID: <20070530.152939.21591222.davem@davemloft.net>
References: <465DC598.5060407@trash.net>
	<20070530.125551.41636333.davem@davemloft.net>
	<20070530221039.GJ11166@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, venkatesh.pallipadi@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759555AbXE3W30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 18:29:26 -0400
In-Reply-To: <20070530221039.GJ11166@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 30 May 2007 17:10:39 -0500

> Are you agreeing that "it seems wasteful to add per-packet overhead"?
> This patch is not doing that.

Yes, and I know that :-)
