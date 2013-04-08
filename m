From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: mvmdio: get and enable optional clock
Date: Mon, 08 Apr 2013 11:32:08 +0200
Message-ID: <51628E98.2070709@openwrt.org>
References: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/07/13 13:09, Sebastian Hesselbarth a =C3=A9crit :
> Marvell mdio driver uses internal registers that can be clock gated o=
n
> some SoCs. This patch just adds optional clock handling, to allow to =
pass
> and enable the corresponding clock.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com=
>

Looks good to me:

Acked-by: Florian Fainelli <florian@openwrt.org>
--
=46lorian
