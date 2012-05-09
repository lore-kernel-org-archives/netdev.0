From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] e1000e: Fix merge conflict (net->net-next)
Date: Wed, 09 May 2012 12:07:10 -0400 (EDT)
Message-ID: <20120509.120710.476288988412846674.davem@davemloft.net>
References: <1336555426-13934-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758214Ab2EIQHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 12:07:18 -0400
In-Reply-To: <1336555426-13934-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  9 May 2012 02:23:46 -0700

> During merge of net to net-next the changes in patch:
> 
> e1000e: Fix default interrupt throttle rate not set in NIC HW
> 
> got munged in param.c of the e1000e driver.  This rectifies the
> merge issues.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
