From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] af-packet: Hold reference to bound network devices.
Date: Sun, 05 Jun 2011 14:16:47 -0700 (PDT)
Message-ID: <20110605.141647.1706156444294375971.davem@davemloft.net>
References: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330Ab1FEVQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:16:49 -0400
In-Reply-To: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed,  1 Jun 2011 10:18:52 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> Old code was probably safe, but with this change we
> can actually use the netdev object, not just compare
> the pointer values.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied to net-next-2.6
