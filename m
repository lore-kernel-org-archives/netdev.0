From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 12/17] net: dsa: add dsa_is_normal_port helper
Date: Sun, 12 Mar 2017 00:49:20 +0100
Message-ID: <20170311234920.GG15842@lunn.ch>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
 <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44862 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751325AbdCKXty (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Mar 2017 18:49:54 -0500
Content-Disposition: inline
In-Reply-To: <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 11, 2017 at 04:12:58PM -0500, Vivien Didelot wrote:
> Introduce a dsa_is_normal_port helper to check if a given port is a
> normal user port as opposed to a CPU port or DSA link.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
