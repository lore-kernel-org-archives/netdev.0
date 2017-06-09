From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: ops cosmetics
Date: Fri, 09 Jun 2017 12:11:20 -0400 (EDT)
Message-ID: <20170609.121120.2149178729617274766.davem@davemloft.net>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  8 Jun 2017 18:34:07 -0400

> This patchset brings no functional changes. It is a first step in a
> bigger cosmetics change to the driver. It simplifies print messages and
> polishes data types and chip operations.
> 
> The next patchs will only prefix and document the port registers macros.
> 
> Changes in v2:
>   - KISS and simply use dev_* since chip->ds may not be initialized
>   - add reviewers tags

Series applied, thank you.
