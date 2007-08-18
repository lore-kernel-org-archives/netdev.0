From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:31:04 -0700 (PDT)
Message-ID: <20070817.183104.99204365.davem@davemloft.net>
References: <20070817.180006.98552435.davem@davemloft.net>
	<46C64995.4030401@intel.com>
	<20070817182807.7591878d@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43592
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753545AbXHRBbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:31:05 -0400
In-Reply-To: <20070817182807.7591878d@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 18:28:07 -0700

> Plan C was replacing MULTIQUEUE boolean with a int value 1 ... 256.
> All this was a one day "what if" exercise, not really a big churn..

Yes, that's another reasonable approach.
