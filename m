From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 00/16] Mellanox 100G SRIOV E-Switch offload
 and VF representors
Date: Fri, 01 Jul 2016 06:16:39 -0400 (EDT)
Message-ID: <20160701.061639.58539315378533703.davem@davemloft.net>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com,
	jiri@mellanox.com, gospo@cumulusnetworks.com,
	jesse.brandeburg@intel.com, john.r.fastabend@intel.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbcGAKRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 06:17:06 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So you have submitted to me, in parallel, two non-trivial sets of changes
to the mlx5 driver.  One for 'net' and one for 'net-next, and at the same
exact time.

You haven't given me any indication of whether there are any dependencies
nor conflicts from these two sets of changes.

So I'm tossing this series until you do so.
