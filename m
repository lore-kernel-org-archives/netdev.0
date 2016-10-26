From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] devlink: Prevent port_type_set() callback
 when it's not needed
Date: Wed, 26 Oct 2016 17:30:52 -0400 (EDT)
Message-ID: <20161026.173052.344643706371876150.davem@davemloft.net>
References: <1477237385-1991-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933736AbcJZVax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 17:30:53 -0400
In-Reply-To: <1477237385-1991-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 23 Oct 2016 17:43:05 +0200

> From: Elad Raz <eladr@mellanox.com>
> 
> When a port_type_set() is been called and the new port type set is the same
> as the old one, just return success.
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
