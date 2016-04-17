From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Minor IFF_NO_QUEUE conversion follow-up
Date: Sat, 16 Apr 2016 22:02:30 -0400 (EDT)
Message-ID: <20160416.220230.726692927623578392.davem@davemloft.net>
References: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcDQCCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 22:02:32 -0400
In-Reply-To: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri, 15 Apr 2016 19:14:18 +0200

> The following series converts two further drivers away from setting
> 'tx_queue_len = 0' to adding IFF_NO_QUEUE to priv_flags instead.
> 
> The first one, rtl8188eu in staging didn't exist back when all drivers
> were converted. The second one, openvswitch seems to have slipped through
> my grep'ing back then, no idea why.

Series applied, thanks Phil.
