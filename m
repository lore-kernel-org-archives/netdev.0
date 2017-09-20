From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: lan9303: Add adjust_link() method
Date: Wed, 20 Sep 2017 14:14:19 -0700 (PDT)
Message-ID: <20170920.141419.292331424149688483.davem@davemloft.net>
References: <20170919080924.11144-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919080924.11144-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Tue, 19 Sep 2017 10:09:24 +0200

> Make the driver react to device tree "fixed-link" declaration on CPU port.
> 
> - turn off autonegotiation
> - force speed 10 or 100 mb/s
> - force duplex mode
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Applied, thank you.
