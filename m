From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Support vxlan offload stats in the
 driver
Date: Wed, 29 Jul 2015 23:54:19 -0700 (PDT)
Message-ID: <20150729.235419.371864185023392531.davem@davemloft.net>
References: <1438178732-29026-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbbG3GyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:54:19 -0400
In-Reply-To: <1438178732-29026-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Date: Wed, 29 Jul 2015 19:35:32 +0530

> This patch adds vxlan offload specific counters to ethtool stats. We
> provide tx/rx queue counters to show the number of vxlan offload pkts
> sent/received.
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>

Applied, thanks.
