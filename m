From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fou: Fix typo in returning flags in netlink
Date: Wed, 05 Nov 2014 22:18:49 -0500 (EST)
Message-ID: <20141105.221849.1431360123291406941.davem@davemloft.net>
References: <1415234978-31931-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaKFDSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:18:51 -0500
In-Reply-To: <1415234978-31931-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed,  5 Nov 2014 16:49:38 -0800

> When filling netlink info, dport is being returned as flags. Fix
> instances to return correct value.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
