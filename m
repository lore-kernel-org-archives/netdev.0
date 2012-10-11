From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet/jme: disable ASPM
Date: Thu, 11 Oct 2012 15:20:41 -0400 (EDT)
Message-ID: <20121011.152041.387981239688261603.davem@davemloft.net>
References: <20121008193316.GA13684@srcf.ucam.org>
	<20121008.153953.2134806395029777705.davem@davemloft.net>
	<20121010225049.024c94cb@laptop-kevin.kbaradon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjg59@srcf.ucam.org, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: kevin.baradon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757953Ab2JKTUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 15:20:43 -0400
In-Reply-To: <20121010225049.024c94cb@laptop-kevin.kbaradon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Baradon <kevin.baradon@gmail.com>
Date: Wed, 10 Oct 2012 22:50:49 +0200

> Subject: [PATCH] net/ethernet/jme: disable ASPM
> 
> Based on patch from Matthew Garrett <mjg@redhat.com> (https://lkml.org/lkml/2011/11/11/168).
> 
> http://driveragent.com/archive/30421/7-0-14 indicates that ASPM is
> disabled on the 250 and 260. Duplicate for sanity.
> 
> Fixes random RX engine hangs I experienced with JMC250 on Clevo W270HU.
> 
> Signed-off-by: Kevin Baradon <kevin.baradon@gmail.com>

Applied.
