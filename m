From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] net/xen-netback: Remove unused code in
 xenvif_rx_action
Date: Sun, 21 Jun 2015 09:41:40 -0700 (PDT)
Message-ID: <20150621.094140.802489063747301063.davem@davemloft.net>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	<1434481848-26387-3-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org
To: julien.grall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbbFUQ3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:29:54 -0400
In-Reply-To: <1434481848-26387-3-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Grall <julien.grall@citrix.com>
Date: Tue, 16 Jun 2015 20:10:47 +0100

> The variables old_req_cons and ring_slots_used are assigned but never
> used since commit 1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b "xen-netback:
> always fully coalesce guest Rx packets".
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>

Applied.
