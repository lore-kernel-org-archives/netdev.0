From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: mvpp2: driver fixes
Date: Sat, 10 Jun 2017 18:23:22 -0400 (EDT)
Message-ID: <20170610.182322.776032065067536322.davem@davemloft.net>
References: <20170610211822.24371-1-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marc.zyngier@arm.com, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        antoine.tenart@free-electrons.com, nadavh@marvell.com,
        hannah@marvell.com, yehuday@marvell.com, mw@semihalf.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdFJWXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:23:24 -0400
In-Reply-To: <20170610211822.24371-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sat, 10 Jun 2017 23:18:20 +0200

> As requested, here is a series of patches containing only bug fixes
> for the mvpp2 driver. It is based on the latest "net" branch.
> 
> Changes since v1:
> 
>  - Fixed a build breakage that occurred when only PATCH 1 was only,
>    and not later patches in the series. Was reported by the kbuild
>    report on the first submission.
> 
>  - Added Tested-by from Marc Zyngier on PATCH 2.

Series applied, thank you.
