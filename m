From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: mISDN: set ->family in ->getname()
Date: Thu, 25 Apr 2013 01:49:05 -0400 (EDT)
Message-ID: <20130425.014905.167442930303199676.davem@davemloft.net>
References: <20130423062414.GC15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab3DYFtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:49:06 -0400
In-Reply-To: <20130423062414.GC15893@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Apr 2013 09:24:14 +0300

> The "maddr->family" variable was not set but instead it leaked stack
> information to userspace.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
