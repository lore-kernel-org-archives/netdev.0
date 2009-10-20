From: David Miller <davem@davemloft.net>
Subject: Re: PATCH [net-next-2.6] IP: Cleanups
Date: Mon, 19 Oct 2009 21:55:30 -0700 (PDT)
Message-ID: <20091019.215530.218126048.davem@davemloft.net>
References: <1255980690.20673.5.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752899AbZJTEzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:55:07 -0400
In-Reply-To: <1255980690.20673.5.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Mon, 19 Oct 2009 14:31:30 -0500

> Use symbols instead of magic constants while checking PMTU discovery
> setsockopt.
> 
> Remove redundant test in ip_rt_frag_needed() (done by caller).
> 
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Applied to net-next-2.6, thanks.
