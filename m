From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Add support for MTU change via port
 profile on a dynamic vnic
Date: Mon, 06 Jun 2011 22:48:56 -0700 (PDT)
Message-ID: <20110606.224856.790719640483405835.davem@davemloft.net>
References: <20110604003517.21165.45654.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab1FGFs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:48:58 -0400
In-Reply-To: <20110604003517.21165.45654.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Fri, 03 Jun 2011 17:35:17 -0700

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> enic driver gets MTU change notifications for MTU changes in the
> port profile associated to a dynamic vnic. This patch adds support
> in enic driver to set new MTU on the dynamic vnic and dynamically
> adjust its buffers with new MTU size in response to such notifications.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Applied, thanks.
