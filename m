From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7]: [NET]: Make ->poll() breakout consistent in Intel
 ethernet drivers.
Date: Tue, 08 Jan 2008 14:55:59 -0800 (PST)
Message-ID: <20080108.145559.77545176.davem@davemloft.net>
References: <20080107.214110.257940011.davem@davemloft.net>
	<4783C95B.8060005@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754265AbYAHW4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:56:00 -0500
In-Reply-To: <4783C95B.8060005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Tue, 08 Jan 2008 11:04:59 -0800

> this is exactly the change I was eyeballing and indeed this seems to be the
> general use case in most drivers anyway.
> 
> I'll try to see how this impacts the (especially 4-port) TX performance issue with
> e1000e, but this should be just fine for now, and we can address later anyway.
> 
> Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
> 

Ok, thanks for reviewing.
