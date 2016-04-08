From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] devlink: share user_ptr pointer for both
 devlink and devlink_port
Date: Fri, 08 Apr 2016 15:40:49 -0400 (EDT)
Message-ID: <20160408.154049.2116825484232145586.davem@davemloft.net>
References: <1460135568-16168-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbcDHTkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:40:52 -0400
In-Reply-To: <1460135568-16168-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  8 Apr 2016 19:12:48 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ptr to devlink structure can be easily obtained from
> devlink_port->devlink. So share user_ptr[0] pointer for both and leave
> user_ptr[1] free for other users.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Applied, thanks again Jiri.
