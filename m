From: David Miller <davem@davemloft.net>
Subject: Re: netconf notes and materials
Date: Fri, 09 Oct 2009 14:51:51 -0700 (PDT)
Message-ID: <20091009.145151.130967664.davem@davemloft.net>
References: <20091007.044718.233642056.davem@davemloft.net>
	<20091009174949.467ddc50.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934493AbZJIVv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 17:51:56 -0400
In-Reply-To: <20091009174949.467ddc50.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 9 Oct 2009 17:49:49 -0400

> How did you do the NUMA memory performance monitoring that was
> presented on one of your slides?

Using proprietary internal tools Intel is unlikely to release.

On the bright side, some of those metrics will make their way into the
'perf' facilities in the kernel so they can be monitored, but not all
of them.

