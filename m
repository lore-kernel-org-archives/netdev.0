From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 00/11] Start adding support for mv88e6390
Date: Tue, 22 Nov 2016 09:56:21 -0500 (EST)
Message-ID: <20161122.095621.1504164617620669284.davem@davemloft.net>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbcKVO4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 09:56:25 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 21 Nov 2016 23:26:54 +0100

> This is the first patchset implementing support for the mv88e6390
> family.  This is a new generation of switch devices and has numerous
> incompatible changes to the registers. These patches allow the switch
> to the detected during probe, and makes the statistics unit work.
> 
> These patches are insufficient to make the mv88e6390 functional. More
> patches will follow.
> 
> v2:
>   Move stats code into global1
>   Change DT compatible string to mv88e6190
>   Fixed mv88e6351 stats which v1 had broken

Series applied, thanks Andrew.
