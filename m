From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in
 mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 12:13:12 -0400 (EDT)
Message-ID: <20150416.121312.749843002683595452.davem@davemloft.net>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbbDPQNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:13:14 -0400
In-Reply-To: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 15 Apr 2015 22:12:42 -0700

> Return correct error code if _mv88e6xxx_reg_read returns an error.
> 
> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging support")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
