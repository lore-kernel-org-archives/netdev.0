From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Sat, 21 Oct 2017 19:06:38 -0700
Message-ID: <92521B8C-6FCF-4F7C-B0D5-BE6A3F5FD021@gmail.com>
References: <1508327643-3579-1-git-send-email-geert+renesas@glider.be> <20171022.023738.2186250991838185660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: andrew@lunn.ch, robh+dt@kernel.org, frowand.list@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, geert+renesas@glider.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171022.023738.2186250991838185660.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On October 21, 2017 6:37:38 PM PDT, David Miller <davem@davemloft=2Enet> wr=
ote:
>
>Second ping, this patch needs a review ASAP=2E
>
>Geert's hard-resetting PHY changes depend upon this change=2E

Done, same concerns as before and we could all improve on trying to get th=
is tested on a pure SW model (e=2Eg QEMU) but there is only so little time=
=2E=2E=2E Regarding the other patch series it needs more love before it get=
s merged, so that hopefully lowers the criticality=2E

--=20
Florian
