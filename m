From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/4] net: dsa: lan9303: Multiply by 4 to get MDIO register
Date: Fri, 28 Jul 2017 11:37:03 -0400
Message-ID: <87lgn8lgio.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no> <20170728151157.28983-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> lan9303_mdio_write()/_read() must multiply register number by 4 to get
> offset.
>
> Added some commments to the register definitions.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
