From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: reg: Fix HTGT register length
Date: Mon, 06 Feb 2017 11:07:45 -0500 (EST)
Message-ID: <20170206.110745.275943973094301863.davem@davemloft.net>
References: <1486385787-2122-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbdBFQHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:07:50 -0500
In-Reply-To: <1486385787-2122-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  6 Feb 2017 13:56:27 +0100

> From: Elad Raz <eladr@mellanox.com>
> 
> HTGT register length is limited to 32 bytes and not 256 bytes.
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thank you.
