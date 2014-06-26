From: David Miller <davem@davemloft.net>
Subject: Re: dependency cycle between libphy and of_mdio
Date: Thu, 26 Jun 2014 01:50:10 -0700 (PDT)
Message-ID: <20140626.015010.1049964034604158112.davem@davemloft.net>
References: <alpine.SOC.1.00.1406261135010.12870@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaFZIuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 04:50:11 -0400
In-Reply-To: <alpine.SOC.1.00.1406261135010.12870@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Thu, 26 Jun 2014 11:36:23 +0300 (EEST)

>   DEPMOD  3.16.0-rc2-00211-gd7933ab
> depmod: ERROR: Found 2 modules in dependency cycles!
> depmod: ERROR: Cycle detected: libphy -> of_mdio -> libphy

We know, a fix was posted an hour or two ago.

Thanks.
