From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix genl_set_err() group ID
Date: Thu, 21 Nov 2013 13:18:14 -0500 (EST)
Message-ID: <20131121.131814.2153004093403859499.davem@davemloft.net>
References: <1385054428-6447-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338Ab3KUSSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:18:15 -0500
In-Reply-To: <1385054428-6447-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Nov 2013 18:20:28 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Fix another really stupid bug - I introduced genl_set_err()
> precisely to be able to adjust the group and reject invalid
> ones, but then forgot to do so.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
