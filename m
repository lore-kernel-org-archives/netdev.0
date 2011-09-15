From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] br: remove redundant check and init
Date: Thu, 15 Sep 2011 15:43:37 -0400 (EDT)
Message-ID: <20110915.154337.325281009742285515.davem@davemloft.net>
References: <1314883778-2706-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934532Ab1IOTpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:45:43 -0400
In-Reply-To: <1314883778-2706-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu,  1 Sep 2011 15:29:38 +0200

> Since these checks and initialization are done in
> dev_ethtool_get_settings called later on, remove this redundancy.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
