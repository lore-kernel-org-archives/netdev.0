From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.2-rc7] skge: restore rx multicast filter on resume
 and after config changes
Date: Fri, 30 Dec 2011 23:33:07 -0500 (EST)
Message-ID: <20111230.233307.358990238456032100.davem@davemloft.net>
References: <20111231033009.GE2698@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab1LaEeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 23:34:20 -0500
In-Reply-To: <20111231033009.GE2698@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Zumbiehl <florz@florz.de>
Date: Sat, 31 Dec 2011 04:30:09 +0100

> Restore skge hardware registers for multicast filtering to their
> appropriate values after system resume and after hardware restarts
> that are done when changing certain settings.
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
