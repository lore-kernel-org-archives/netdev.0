From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Tue, 13 Oct 2015 04:42:49 -0700 (PDT)
Message-ID: <20151013.044249.313207524992614454.davem@davemloft.net>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
	<1444651299-2813-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbbJML0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:26:49 -0400
In-Reply-To: <1444651299-2813-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 12 Oct 2015 14:01:39 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
