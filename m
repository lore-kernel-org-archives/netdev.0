From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: make irq_chip const
Date: Sat, 19 Aug 2017 15:25:40 +0200
Message-ID: <20170819132540.GA15612@lunn.ch>
References: <1503140152-7719-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503140152-7719-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 04:25:52PM +0530, Bhumika Goyal wrote:
> Make this const as it is only used in a copy operation.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
