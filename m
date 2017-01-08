From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: move HWMON support to its own file
Date: Sat, 07 Jan 2017 22:42:27 -0500 (EST)
Message-ID: <20170107.224227.1527412731313171593.davem@davemloft.net>
References: <20170106214200.15633-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752528AbdAHDmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 22:42:33 -0500
In-Reply-To: <20170106214200.15633-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  6 Jan 2017 16:42:00 -0500

> Isolate the HWMON support in DSA in its own file. Currently only the
> legacy DSA code is concerned.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
