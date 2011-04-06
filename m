From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix panic in ip6_pol_route
Date: Wed, 06 Apr 2011 00:41:50 -0700 (PDT)
Message-ID: <20110406.004150.226756417.davem@davemloft.net>
References: <20110406064504.30691.36599.sendpatchset@krkumar2.in.ibm.com>
	<20110406.004043.193732725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab1DFHm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 03:42:27 -0400
In-Reply-To: <20110406.004043.193732725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Apr 2011 00:40:43 -0700 (PDT)

> Having IFF_LOOPBACK be set on a loopback device is even more
> stupid.

I mean "VLAN device" here of course.
