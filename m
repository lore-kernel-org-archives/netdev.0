From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/5] net: mdio-mux: printing driver version is useless
Date: Wed, 30 Aug 2017 20:46:58 +0200
Message-ID: <20170830184658.GF22289@lunn.ch>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
 <20170830174651.30325-4-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170830174651.30325-4-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 07:46:49PM +0200, Corentin Labbe wrote:
> Remove the driver version information because this information
> is not useful in an upstream kernel driver.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Hi Corentin

You may as well remove DRV_VERSION from this file, not just here.

    Andrew
