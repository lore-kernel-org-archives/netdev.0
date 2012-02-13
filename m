From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Fix address deregistration for
 sriov vf during port profile disassociate
Date: Mon, 13 Feb 2012 00:51:12 -0500 (EST)
Message-ID: <20120213.005112.91394233269551585.davem@davemloft.net>
References: <20120212073737.7768.99208.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab2BMFvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 00:51:16 -0500
In-Reply-To: <20120212073737.7768.99208.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Sat, 11 Feb 2012 23:37:37 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> This patch fixes erroneous PF address deregistration in cases where
> a port profile disassociate is called on an already disassociated interface.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: sujith sankar <ssujith@cisco.com>
> Signed-off-by: ChingWei Chang <cwchang@cisco.com>

Applied.
