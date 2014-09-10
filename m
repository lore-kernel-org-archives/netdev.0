From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Wed, 10 Sep 2014 10:06:19 +0200
Message-ID: <4343050.11meBDLdD4@wuerfel>
References: <20140910144837.5e3089e1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Olof Johansson <olof@lixom.net>, linux-next@vger.kernel.org,
	Romain Perier <romain.perier@gmail.com>,
	linux-kernel@vger.kernel.org,
	Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140910144837.5e3089e1@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 September 2014 14:48:37 Stephen Rothwell wrote:
> Today's linux-next merge of the net-next tree got a conflict in
> arch/arm/boot/dts/rk3188-radxarock.dts between commit 4721ab855d1a
> ("ARM: dts: rockchip: add hym8563 rtc to Radxa Rock board") from the
> arm-soc tree and commit c6ec956b73db ("ARM: dts: Enable emac node on
> the rk3188-radxarock boards") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
> 

Thanks, looks good.

	Arnd
