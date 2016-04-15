From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] devlink: fix sb register stub in case devlink
 is disabled
Date: Fri, 15 Apr 2016 12:57:45 -0400 (EDT)
Message-ID: <20160415.125745.647243932188429967.davem@davemloft.net>
References: <1460704628-3662-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, fengguang.wu@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbcDOQ5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 12:57:50 -0400
In-Reply-To: <1460704628-3662-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 15 Apr 2016 09:17:08 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: bf7974710a40 ("devlink: add shared buffer configuration")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
