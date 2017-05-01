From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/18] net: dsa: mv88e6xxx: 802.1s and
 88E6390 VTU
Date: Mon, 01 May 2017 15:03:31 -0400 (EDT)
Message-ID: <20170501.150331.482828978106025762.davem@davemloft.net>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdEATDd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:03:33 -0400
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  1 May 2017 14:05:09 -0400

> This patch series adds support for the VLAN Table Unit (a.k.a. the VTU)
> to the 88E6390 family of Marvell Ethernet switch chips. The plumbing for
> the per VLAN Spanning Tree support is added as a side effect of the
> necessary refactoring.

Series applied, thanks.
