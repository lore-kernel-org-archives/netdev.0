From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: fix chip definitions
Date: Tue, 28 Mar 2017 21:54:32 -0700 (PDT)
Message-ID: <20170328.215432.2302942403950373182.davem@davemloft.net>
References: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752162AbdC2Eye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 00:54:34 -0400
In-Reply-To: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 28 Mar 2017 13:50:31 -0400

> The definitions of some of the mv88e6xxx_ops and mv88e6xxx_info
> structures are misordered and erroneous for 88E6191 and 88E6391.
> 
> This patch series cleans that up.

Series applied.
