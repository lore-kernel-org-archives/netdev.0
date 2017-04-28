From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 13/18] net: dsa: mv88e6xxx: add VTU GetNext
 operation
Date: Fri, 28 Apr 2017 04:10:11 +0200
Message-ID: <20170428021011.GC13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-14-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43994 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162764AbdD1CKS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 22:10:18 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-14-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:31AM -0400, Vivien Didelot wrote:
> Add a new vtu_getnext operation to the chip info structure to differ the
> various implementations of the VTU accesses.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
