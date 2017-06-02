From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Fri, 02 Jun 2017 14:22:51 -0400 (EDT)
Message-ID: <20170602.142251.851089443438560012.davem@davemloft.net>
References: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Wed, 31 May 2017 15:43:30 -0400

> use of_mdio_parse_addr() in place of an OF read of reg and a bounds
> check (which is litterally the exact same thing that
> of_mdio_parse_addr() does)
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Applied, thanks Jon.
