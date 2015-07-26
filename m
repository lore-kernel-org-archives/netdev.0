From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Allow firmware flash, only if cxgb4 is
 the master driver
Date: Sun, 26 Jul 2015 16:38:15 -0700 (PDT)
Message-ID: <20150726.163815.1355435878971452508.davem@davemloft.net>
References: <1437585890-7405-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168AbbGZXiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:38:16 -0400
In-Reply-To: <1437585890-7405-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 22 Jul 2015 22:54:50 +0530

> Adapter can go for a toss, if cxgb4 is loaded as slave and we try to
> upgrade the firmware. So add a check for the same before flashing
> firmware using ethtool.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
