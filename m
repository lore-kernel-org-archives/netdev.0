From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] core: remove unneded headers for net cgroup
 controllers.
Date: Wed, 17 Feb 2016 15:32:04 -0500 (EST)
Message-ID: <20160217.153204.567765453264387.davem@davemloft.net>
References: <1455496783-8478-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tj@kernel.org, nhorman@tuxdriver.com,
	tgraf@suug.ch
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbcBQUcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 15:32:06 -0500
In-Reply-To: <1455496783-8478-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Mon, 15 Feb 2016 02:39:43 +0200

> commit 3ed80a6 (cgroup: drop module support) made including 
> module.h redundant in the net cgroup controllers, 
> netclassid_cgroup.c and netprio_cgroup.c. This patch 
> removes them.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thank you.
