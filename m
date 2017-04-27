From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/18] net: dsa: mv88e6xxx: move STU GetNext
 operation
Date: Thu, 27 Apr 2017 21:43:01 +0200
Message-ID: <20170427194301.GM17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43752 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937343AbdD0TnG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:43:06 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-11-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:28AM -0400, Vivien Didelot wrote:
> Extract the generic portion of code to issue an STU GetNext operation,
> which will be used in other implementations.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
