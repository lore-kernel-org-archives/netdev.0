From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bna: Update driver version to 3.0.23.0
Date: Mon, 26 Mar 2012 18:12:59 -0400 (EDT)
Message-ID: <20120326.181259.2238188203579362214.davem@davemloft.net>
References: <1332790673-9562-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: huangj@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757674Ab2CZWOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 18:14:03 -0400
In-Reply-To: <1332790673-9562-1-git-send-email-huangj@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Huang <huangj@Brocade.COM>
Date: Mon, 26 Mar 2012 12:37:53 -0700

> This patch set contains fixes in adapter initialization and tx/rx cleanup path.
> It also include code cleanups by removing and renaming some functions.
> 
> The driver version has been updated to 3.0.23.0 to reflect the changes.

Cleanups and such are only appropriate for net-next, which is not
open because the merge window is still ongoing.
