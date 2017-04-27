From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 11/18] net: dsa: mv88e6xxx: get STU entry on VTU
 GetNext
Date: Thu, 27 Apr 2017 22:17:39 +0200
Message-ID: <20170427201739.GN17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43810 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754875AbdD0URn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 16:17:43 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-12-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:29AM -0400, Vivien Didelot wrote:
> Now that the code reads both VTU and STU data on VTU GetNext operation,
> fetch the STU entry data of a VTU entry at the same time.
> 
> The STU data bits are masked with the VTU data bits and they are now all
> read at the same time a VTU GetNext operation is issued.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
