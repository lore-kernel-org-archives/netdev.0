From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/8] qlcnic: ethtool enhancements and code
 cleanup.
Date: Fri, 18 Oct 2013 13:42:53 -0400 (EDT)
Message-ID: <20131018.134253.1639260189585974733.davem@davemloft.net>
References: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab3JRRmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:42:55 -0400
In-Reply-To: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Fri, 18 Oct 2013 12:22:27 -0400

> This patch series contains
> 
> o updates to ethtool for pause settings and enhance
>   register dump to display mask and ring indices.
> o cleanup in DCB code and remove redundant eSwitch enablement command.
> o fixed firmware dump collection logic to skip unknown entries.
> 
> Changes from v3 -> v4
> o Dropped patch for Tx queue validation to be submitted in net.
> 
> Changes from v2 -> v3
> 
> o Updated patch to print informational messages as per Joe Perches's comment.
> 
> Changes from v1 -> v2
> 
> o Dropped patch to register device if adapter is in FAILED state for more rework.
> o Updated patch to display ring indices via ethtool per Ben Hutchings's comment.
> o Update patch for DCB cleanup per Stephen Hemminger's comment.
> 
> Please apply to net-next.

Series applied, thanks.
