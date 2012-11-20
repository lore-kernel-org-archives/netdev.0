From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove unnecessary wireless includes
Date: Mon, 19 Nov 2012 19:10:55 -0500 (EST)
Message-ID: <20121119.191055.647087881985988633.davem@davemloft.net>
References: <1353099561-14339-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab2KTAK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:10:57 -0500
In-Reply-To: <1353099561-14339-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 16 Nov 2012 21:59:21 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> The wireless and wext includes in net-sysfs.c aren't
> needed, so remove them.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
