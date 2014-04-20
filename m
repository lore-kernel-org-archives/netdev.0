From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 1/2] net: phy: export
 genphy_config_init()
Date: Sun, 20 Apr 2014 18:19:07 -0400 (EDT)
Message-ID: <20140420.181907.929288881344389071.davem@davemloft.net>
References: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaDTWTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:19:12 -0400
In-Reply-To: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Wed, 16 Apr 2014 17:19:12 +0200

> This enables other drivers to call this generic implementation, and then
> only do specific details on top of it.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Applied.
