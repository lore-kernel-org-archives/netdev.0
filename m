From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: update the usage of CHECKSUM_UNNECESSARY
Date: Mon, 19 Mar 2012 17:38:31 -0400 (EDT)
Message-ID: <20120319.173831.1211229350097883207.davem@davemloft.net>
References: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@open-fcoe.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176Ab2CSVij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:38:39 -0400
In-Reply-To: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>
Date: Mon, 19 Mar 2012 14:12:41 -0700

> As suggested by Ben, this adds the clarification on the usage of
> CHECKSUM_UNNECESSARY on the outgoing patch. Also add the usage
> description of NETIF_F_FCOE_CRC and CHECKSUM_UNNECESSARY
> for the kernel FCoE protocol driver.
> 
> This is a follow-up to the following:
> http://patchwork.ozlabs.org/patch/147315/
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: www.Open-FCoE.org <devel@open-fcoe.org>

Applied.
