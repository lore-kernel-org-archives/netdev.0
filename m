From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: Introduce support for offload
 forward mark
Date: Fri, 26 Aug 2016 13:14:05 -0700 (PDT)
Message-ID: <20160826.131405.2118666831071325872.davem@davemloft.net>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753891AbcHZUOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 16:14:06 -0400
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 25 Aug 2016 18:42:35 +0200

> Ido says:
> This patchset enables the forwarding of certain control packets by the
> device instead of relying on the CPU to do the forwarding.
> 
> The first two patches simplify the current switchdev offload forward
> infrastructure and make it usable for stacked devices. This is done by
> moving the packet and port marking to the bridge driver instead of the
> switch driver.
> 
> Patches 3-5 add the mlxsw specific bits to support the forward mark.

Series applied, thanks.
