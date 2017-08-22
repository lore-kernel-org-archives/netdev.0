From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mdio-gpio: make mdiobb_ops const
Date: Tue, 22 Aug 2017 15:15:12 +0200
Message-ID: <20170822131512.GE24555@lunn.ch>
References: <1503389609-17490-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503389609-17490-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 01:43:29PM +0530, Bhumika Goyal wrote:
> Make this const as it is only stored in a const field of a
> mdiobb_ctrl structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
