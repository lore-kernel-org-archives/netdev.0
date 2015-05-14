From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: batch of last_rx update avoidance in
 ethernet drivers.
Date: Thu, 14 May 2015 17:38:34 -0400 (EDT)
Message-ID: <20150514.173834.1491713989531938257.davem@davemloft.net>
References: <20150514181722.GA8041@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	thomas.lendacky@amd.com, zhangfei.gao@linaro.org,
	jeffrey.t.kirsher@intel.com, w-kwok2@ti.com, m-karicheri2@ti.com,
	cmetcalf@tilera.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422652AbbENVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:38:40 -0400
In-Reply-To: <20150514181722.GA8041@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 14 May 2015 20:17:22 +0200

> None of those drivers uses last_rx for its own needs.
> 
> See 4dc89133f49b8cfd77ba7e83f5960aed63aaa99e ("net: add a comment on
> netdev->last_rx") for reference.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Looks good, applied, thanks!
