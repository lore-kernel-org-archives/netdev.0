From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 15:47:11 -0500 (EST)
Message-ID: <20130129.154711.992523979276454130.davem@davemloft.net>
References: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
	<1359489540-14620-1-git-send-email-milos.vyletel@sde.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: milos.vyletel@sde.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab3A2UrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:47:12 -0500
In-Reply-To: <1359489540-14620-1-git-send-email-milos.vyletel@sde.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Milos Vyletel <milos.vyletel@sde.cz>
Date: Tue, 29 Jan 2013 14:59:00 -0500

> When bonding module is loaded with primary parameter and one decides to unset
> primary slave using sysfs these settings are not preserved during bond device
> restart. Primary slave is only unset once and it's not remembered in
> bond->params structure. Below is example of recreation.
 ...
> 
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
