From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: core: Use correct EMAD transaction ID
 in debug message
Date: Wed, 02 Aug 2017 16:59:06 -0700 (PDT)
Message-ID: <20170802.165906.1185947476399290648.davem@davemloft.net>
References: <20170802075210.1000-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdHBX7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:59:08 -0400
In-Reply-To: <20170802075210.1000-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  2 Aug 2017 09:52:10 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> 'trans->tid' is only assigned later in the function, resulting in a zero
> transaction ID. Use 'tid' instead.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
