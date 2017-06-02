From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: Move dsa_switch_{suspend,resume} out of
 legacy.c
Date: Fri, 2 Jun 2017 15:53:40 +0200
Message-ID: <20170602135340.GJ12261@lunn.ch>
References: <20170602025304.14298-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170602025304.14298-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2017 at 07:53:04PM -0700, Florian Fainelli wrote:
> dsa_switch_suspend() and dsa_switch_resume() are functions that belong in
> net/dsa/dsa.c and are not part of the legacy platform support code.
> 
> Fixes: a6a71f19fe5e ("net: dsa: isolate legacy code")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
