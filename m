From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/16] mlxsw: Add Infiniband support for
 Mellanox switches
Date: Sun, 30 Oct 2016 16:51:07 -0400 (EDT)
Message-ID: <20161030.165107.1773338771250882750.davem@davemloft.net>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbcJ3UvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:51:14 -0400
In-Reply-To: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 28 Oct 2016 21:17:34 +0200

> This patchset adds basic Infiniband support for SwitchX-2, Switch-IB
> and Switch-IB-2 ASIC drivers.

This depended upon the bug fixes which were only in 'net' until a few
hours ago.

Please state this explicitly in the future, it'll save me time.

Series applied, thanks.
