From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: vlan: fix up vlan_proto_idx() for CONFIG_BUG=n
Date: Sun, 21 Apr 2013 15:58:32 -0400 (EDT)
Message-ID: <20130421.155832.1786074011866971971.davem@davemloft.net>
References: <1366538974-4589-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab3DUT6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 15:58:34 -0400
In-Reply-To: <1366538974-4589-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 21 Apr 2013 12:09:32 +0200

> Add missing return statement for CONFIG_BUG=n.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
