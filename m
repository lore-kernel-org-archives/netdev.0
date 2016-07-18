From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 09/12] net: dsa: mv88e6xxx: add cap for IRL
Date: Mon, 18 Jul 2016 21:42:21 +0200
Message-ID: <20160718194221.GQ31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44979 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbcGRTmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:42:23 -0400
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-10-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 02:46:25PM -0400, Vivien Didelot wrote:
> Add capability flags to describe the presence of Ingress Rate Limit unit
> registers and an helper function to clear it.
> 
> In the meantime, fix a few harmless issues:
> 
>   - 6185 and 6095 don't have such registers (reserved)
>   - the previous code didn't wait for the IRL operation to complete
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
