From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] of_mdio: Fix broken PHY IRQ in case of probe
 deferral
Date: Sun, 22 Oct 2017 02:37:38 +0100 (WEST)
Message-ID: <20171022.023738.2186250991838185660.davem@davemloft.net>
References: <1508327643-3579-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, robh+dt@kernel.org,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1508327643-3579-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Second ping, this patch needs a review ASAP.

Geert's hard-resetting PHY changes depend upon this change.

Thank you.
