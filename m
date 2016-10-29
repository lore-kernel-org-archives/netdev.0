From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: Remove redundant variable
Date: Sat, 29 Oct 2016 14:59:45 -0400 (EDT)
Message-ID: <20161029.145945.409508831850268580.davem@davemloft.net>
References: <1477472583-11710-1-git-send-email-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org, mlxsw@mellanox.com,
        idosch@mellanox.com
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbcJ2S7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:59:47 -0400
In-Reply-To: <1477472583-11710-1-git-send-email-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: idosch@idosch.org
Date: Wed, 26 Oct 2016 12:03:03 +0300

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Instead of storing return value in 'err' and returning, just return
> directly.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied.
