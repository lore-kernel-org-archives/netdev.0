From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/9] mlxsw: Replace Hw related const with
 resource query results
Date: Wed, 21 Sep 2016 01:02:59 -0400 (EDT)
Message-ID: <20160921.010259.1969524048493223497.davem@davemloft.net>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbcIUFDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 01:03:03 -0400
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 20 Sep 2016 11:16:48 +0200

> Many of the ASIC's properties can be read from the HW with resources query.
> This patchset adds new resources to the resource query and implement
> using them, instead of the constants that we currently use.
> Those resources are lag, kvd and router related.

Series applied, thanks.
