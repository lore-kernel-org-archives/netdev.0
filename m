From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/11] net: L3 master device
Date: Tue, 29 Sep 2015 16:23:06 -0700 (PDT)
Message-ID: <20150929.162306.94737407786085218.davem@davemloft.net>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbI2XXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:23:09 -0400
In-Reply-To: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 28 Sep 2015 10:16:50 -0700

> v2
> - rebased to top of net-next
> 
> - addressed Niks comments (checking master, removing extra lines, and
>   flipping the order of patches 1 and 2)

This still needs some work:

ERROR: "l3mdev_master_ifindex_rcu" [net/ipv6/ipv6.ko] undefined!
scripts/Makefile.modpost:90: recipe for target '__modpost' failed
make[1]: *** [__modpost] Error 1
Makefile:1095: recipe for target 'modules' failed
make: *** [modules] Error 2
