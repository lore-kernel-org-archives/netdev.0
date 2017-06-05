From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: dsa: mv88e6xxx: move registers macros
Date: Sun, 04 Jun 2017 20:08:13 -0400 (EDT)
Message-ID: <20170604.200813.315564116465334318.davem@davemloft.net>
References: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFEAIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 20:08:19 -0400
In-Reply-To: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  2 Jun 2017 17:06:14 -0400

> This patchset brings no functional changes.
> 
> It is the first step of a cleanup renaming the chip header file and
> moving the Register definitions _as is_ in their proper header files.
> 
> A following patchset will prefix them with the appropriate model
> (MV88E6XXX_ or e.g. MV88E6390_) to respect an implicit namespace and
> easily identify model subtleties in registers layout, as correctly done
> in the newly added serdes.h header.

Series applied, thank you.
