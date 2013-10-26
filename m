From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] qlcnic: Bug fixes
Date: Sat, 26 Oct 2013 00:05:49 -0400 (EDT)
Message-ID: <20131026.000549.2135341232449385506.davem@davemloft.net>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab3JZEFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 00:05:53 -0400
In-Reply-To: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 25 Oct 2013 10:38:35 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch series contains following fixes-
> * Performace drop because driver was forcing adapter not to check
>   destination IP for LRO.
> * driver was not issuing qlcnic_fw_cmd_set_drv_version() to 83xx adapter
>   becasue of improper handling of QLCNIC_FW_CAPABILITY_MORE_CAPS bit.
> 
> Please apply to net.

Applied, what exactly does that destination IP check do?
