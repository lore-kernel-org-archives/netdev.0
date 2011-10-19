From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Tue, 18 Oct 2011 23:47:23 -0400 (EDT)
Message-ID: <20111018.234723.1235424375699917420.davem@davemloft.net>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
	<4E972301.4030004@intel.com>
	<CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, hans.schillstrom@ericsson.com,
	jpirko@redhat.com, mbizon@freebox.fr, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab1JSDrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:47:37 -0400
In-Reply-To: <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 13 Oct 2011 17:22:02 -0700

> Actually, for most of 2.6.x the behavior was somewhat
> non-deterministic since it depended on kernel version and the NIC.  As
> a result, I think we can safely say that this wasn't a particularly
> firm interface that we have to be wedded to.  Based on overwhelming
> feedback, I think the interface in this patch is the preferred one and
> what we should stabilize on.

Agreed, and I've applied this patch to net-next, thanks everyone!
