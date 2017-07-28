From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/4] net: dsa: lan9303: Fix lan9303_detect_phy_setup() for MDIO
Date: Fri, 28 Jul 2017 11:36:37 -0400
Message-ID: <87o9s4lgje.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no> <20170728151157.28983-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Handle that MDIO read with no response return 0xffff.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
