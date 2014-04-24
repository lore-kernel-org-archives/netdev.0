From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Altera TSE: Remove unnecessary cast of void pointers
Date: Thu, 24 Apr 2014 16:51:55 -0400 (EDT)
Message-ID: <20140424.165155.1939582645482123428.davem@davemloft.net>
References: <1398340209-3887-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbaDXUv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:51:57 -0400
In-Reply-To: <1398340209-3887-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 24 Apr 2014 13:50:09 +0200

> No need to cast void pointers.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
