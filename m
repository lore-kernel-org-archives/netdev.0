From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Reverse sense of promisc tests in ip6_mc_input
Date: Mon, 14 May 2007 03:00:53 -0700 (PDT)
Message-ID: <20070514.030053.71090843.davem@davemloft.net>
References: <20070512225135.GA1143@nc.rr.com>
	<OFFD46637C.90C02CF8-ON882572DA.0001BA3C-882572DA.0001E6DB@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: crm-netdev@the-machine.mutternet.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755234AbXENKAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:00:48 -0400
In-Reply-To: <OFFD46637C.90C02CF8-ON882572DA.0001BA3C-882572DA.0001E6DB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Sat, 12 May 2007 17:21:10 -0700

> Your patch looks correct to me.
> 
>                         +-DLS
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Patch applied, thanks Corey and David for reviewing.

I'll push this to -stable too.
