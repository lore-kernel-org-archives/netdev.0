From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] mlxsw: Couple of fixes
Date: Fri, 04 Aug 2017 11:17:29 -0700 (PDT)
Message-ID: <20170804.111729.2166154964834680858.davem@davemloft.net>
References: <20170804121230.2144-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdHDSRb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 14:17:31 -0400
In-Reply-To: <20170804121230.2144-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  4 Aug 2017 14:12:28 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> The first patch prevents us from warning about valid situations that can
> happen due to the fact that some operations in switchdev are deferred.
> 
> Second patch fixes a long standing problem in which we didn't correctly
> free resources upon module removal, resulting in a memory leak.

Series applied, thanks!
