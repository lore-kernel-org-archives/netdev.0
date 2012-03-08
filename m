From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Fix addr valid check in
 enic_set_vf_mac
Date: Thu, 08 Mar 2012 00:28:51 -0800 (PST)
Message-ID: <20120308.002851.1503291365665881119.davem@davemloft.net>
References: <20120307135044.17957.92254.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab2CHI2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:28:54 -0500
In-Reply-To: <20120307135044.17957.92254.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Wed, 07 Mar 2012 05:50:44 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> zero mac address is a valid address for VIC dynamic vnic and sriov Vf's.
> Fix the check in enic_set_vf_mac appropriately
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Sujith Sankar <ssujith@cisco.com>

Applied.
