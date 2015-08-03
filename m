From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: mdb: fix vlan_enabled access when
 vlans are not configured
Date: Mon, 03 Aug 2015 16:21:06 -0700 (PDT)
Message-ID: <20150803.162106.34968979073178630.davem@davemloft.net>
References: <201508040606.8x0wKgcJ%fengguang.wu@intel.com>
	<1438643998-9259-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbbHCXVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 19:21:08 -0400
In-Reply-To: <1438643998-9259-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue,  4 Aug 2015 01:19:58 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Instead of trying to access br->vlan_enabled directly use the provided
> helper br_vlan_enabled().
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
