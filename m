From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cipso: cleanup cipso_v4_translate() when
 !CONFIG_NETLABEL
Date: Tue, 10 Dec 2013 17:57:10 -0500 (EST)
Message-ID: <20131210.175710.1082991964795680930.davem@davemloft.net>
References: <20131210200050.5847.32493.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3LJW5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:57:11 -0500
In-Reply-To: <20131210200050.5847.32493.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 10 Dec 2013 15:00:50 -0500

> Don't needlessly recompute 'opt[opt_iter + 1]' as we already have it
> stored in 'tag_len'.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, thanks Paul.
