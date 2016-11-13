From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] Start adding support for mv88e6390
 family
Date: Sun, 13 Nov 2016 00:48:59 -0500 (EST)
Message-ID: <20161113.004859.749028544003333521.davem@davemloft.net>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751481AbcKMFtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 00:49:04 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 11 Nov 2016 03:53:32 +0100

> This is the first patchset implementing support for the mv88e6390
> family.  This is a new generation of switch devices and has numerous
> incompatible changes to the registers. These patches allow the switch
> to the detected during probe, and makes the statistics unit work.
> 
> These patches are insufficient to make the mv88e6390 functional. More
> patches will follow.

Andrew, this series doesn't apply cleanly to net-next, so you'll
need to respin.

Thanks.
