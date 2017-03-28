From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/4] net: dsa: mv88e6xxx: reorder 88E6141
 definitions
Date: Tue, 28 Mar 2017 20:52:59 +0200
Message-ID: <20170328185259.GA2268@lunn.ch>
References: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
 <20170328175035.13897-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38188 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752617AbdC1SxE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 14:53:04 -0400
Content-Disposition: inline
In-Reply-To: <20170328175035.13897-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 01:50:32PM -0400, Vivien Didelot wrote:
> The related mv88e6xxx_ops and mv88e6xxx_info structure were misplaced.
> Reorder them correctly to fix this.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
