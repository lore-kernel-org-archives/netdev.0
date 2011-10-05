From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: remove some dead code
Date: Wed, 05 Oct 2011 17:52:39 -0400 (EDT)
Message-ID: <20111005.175239.2083304914393777254.davem@davemloft.net>
References: <20111005054918.GC32077@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934884Ab1JEVwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:52:44 -0400
In-Reply-To: <20111005054918.GC32077@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 5 Oct 2011 08:49:18 +0300

> This code is after the break statement so it never gets used.  The
> "vlan_mac_obj" variable does get initialized properly, so we can just
> delete this.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
