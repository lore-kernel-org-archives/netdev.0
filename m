From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Add FIB abort warning
Date: Thu, 10 Nov 2016 13:07:08 -0500 (EST)
Message-ID: <20161110.130708.1708778361439635208.davem@davemloft.net>
References: <1478776229-4722-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753901AbcKJSHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 13:07:11 -0500
In-Reply-To: <1478776229-4722-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 10 Nov 2016 12:10:29 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Add a warning that the abort mechanism was triggered for device.
> Also avoid going through the procedure if abort was already done.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Ido Schimmel <idosch@mellanox.com>

Applied.
