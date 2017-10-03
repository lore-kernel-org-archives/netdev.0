From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mt7530: make functions mt7530_phy_write static
Date: Tue, 3 Oct 2017 14:42:08 +0200
Message-ID: <20171003124208.GF13548@lunn.ch>
References: <20171003104633.27151-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171003104633.27151-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2017 at 11:46:33AM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The function mt7530_phy_write is local to the source and does not need to
> be in global scope, so make it static.
> 
> Cleans up sparse warnings:
> symbol 'mt7530_phy_write' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
