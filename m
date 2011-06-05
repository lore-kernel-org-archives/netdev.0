From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v3] af-packet: Use existing netdev reference for
 bound sockets.
Date: Sun, 05 Jun 2011 14:16:53 -0700 (PDT)
Message-ID: <20110605.141653.1867783545062431076.davem@davemloft.net>
References: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
	<1306948733-22441-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1FEVQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:16:55 -0400
In-Reply-To: <1306948733-22441-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed,  1 Jun 2011 10:18:53 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> This saves a network device lookup on each packet transmitted,
> for sockets that are bound to a network device.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied to net-next-2.6
