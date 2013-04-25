From: David Miller <davem@davemloft.net>
Subject: Re: [patch] appletalk: info leak in ->getname()
Date: Thu, 25 Apr 2013 01:48:44 -0400 (EDT)
Message-ID: <20130425.014844.1797382708245977114.davem@davemloft.net>
References: <20130423062215.GA15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3DYFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:48:45 -0400
In-Reply-To: <20130423062215.GA15893@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Apr 2013 09:22:15 +0300

> There is a one byte hole between ->sat_port and ->sat_addr.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
