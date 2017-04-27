From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/18] net: dsa: mv88e6xxx: move VTU flush
Date: Thu, 27 Apr 2017 20:34:17 +0200
Message-ID: <20170427183417.GG17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43675 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030521AbdD0SeT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 14:34:19 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-5-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:22AM -0400, Vivien Didelot wrote:
> Move the VTU flush operation to global1_vtu.c and call it from a
> mv88e6xxx_vtu_setup helper, similarly to the ATU and PVT setup.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
