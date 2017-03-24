From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: Query resources from firmware
Date: Fri, 24 Mar 2017 13:54:37 -0700 (PDT)
Message-ID: <20170324.135437.689185178074963182.davem@davemloft.net>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934714AbdCXUyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:54:39 -0400
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 24 Mar 2017 08:02:46 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> Some parts of the driver already use the resource query mechanism, but
> in other parts we still rely on hard coded values that may change over
> time.
> 
> This patchset removes most of these remaining values and queries them
> from the firmware instead.

Series applied, thanks Jiri.
