From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qed: Fix dependencies and warnings series
Date: Fri, 14 Oct 2016 11:07:49 -0400 (EDT)
Message-ID: <20161014.110749.281611802201976690.davem@davemloft.net>
References: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, dan.carpenter@oracle.com
To: Yuval.Mintz@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcJNPHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:07:51 -0400
In-Reply-To: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
Date: Thu, 13 Oct 2016 22:57:00 +0300

> The first patch in this series follows Dan Carpenter's reports about
> Smatch warnings for recent qed additions and fixes those.
> 
> The second patch is the most significant one [and the reason this is
> ntended for 'net'] - it's based on Arnd Bermann's suggestion for fixing
> compilation issues that were introduced with the roce addition as a result
> of certain combinations of qed, qede and qedr Kconfig options.
> 
> The third follows the discussion with Arnd and clears a lot of the warnings
> that arise when compiling the drivers with "C=1".
> 
> Please consider applying this series to 'net'.

Series applied, thanks.
