From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/18] net: dsa: mv88e6xxx: move VTU Operation
 accessors
Date: Thu, 27 Apr 2017 20:33:17 +0200
Message-ID: <20170427183317.GF17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43670 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034659AbdD0SdT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 14:33:19 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:21AM -0400, Vivien Didelot wrote:
> Move the helper functions to access the Global 1 VTU Operation register
> to a new global1_vtu.c file, and get rid of the old underscore prefix
> naming convention. This file will be extended will all VTU/STU related
> code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
