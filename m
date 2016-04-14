From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/5] qed/qede: Add VXLAN tunnel slowpath
 configuration support
Date: Thu, 14 Apr 2016 15:26:01 -0400 (EDT)
Message-ID: <20160414.152601.1422370571524886675.davem@davemloft.net>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
	<1460612313-20323-3-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcDNT0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:26:04 -0400
In-Reply-To: <1460612313-20323-3-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 14 Apr 2016 01:38:30 -0400

> This patch enables VXLAN tunnel on the adapter and
> add support for driver hooks to configure UDP ports
> for VXLAN tunnel offload to be performed by the adapter.
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Why do you call all of these offloads the "slowpath"?
