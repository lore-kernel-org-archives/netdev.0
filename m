From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] net: dsa: mv88e6xxx: factorize in-chip
 bridge map
Date: Thu, 30 Mar 2017 16:04:17 +0200
Message-ID: <20170330140417.GF17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40571 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933426AbdC3OEW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 10:04:22 -0400
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-7-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 04:30:17PM -0400, Vivien Didelot wrote:
> Factorize the code in the DSA port_bridge_{join,leave} routines used to
> program the port VLAN map of all local ports of a given bridge group.
> 
> In the meantime shorten the _mv88e6xxx_port_based_vlan_map to get rid of
> the old underscore prefix naming convention.

Hi Vivien

"At the same time ..." would be better English.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
