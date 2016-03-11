From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] qed: Management firmware updates
Date: Fri, 11 Mar 2016 15:20:38 -0500 (EST)
Message-ID: <20160311.152038.919174177754046894.davem@davemloft.net>
References: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbcCKUUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 15:20:41 -0500
In-Reply-To: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 9 Mar 2016 09:16:22 +0200

> This series contains several changes to driver interaction with the
> management fw.
> The biggest [& most significant] change here is a change in the locking
> scheme and re-definition of the 'critical section' when accessing shared
> resources toward the goal of interacting with the management firmware.

Series applied, thanks.
