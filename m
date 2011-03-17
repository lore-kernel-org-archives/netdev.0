From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Thu, 17 Mar 2011 11:24:17 +0100
Message-ID: <1300357457.3133.92.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300355238-1619-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300355238-1619-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 17:47 +0800, Po-Yu Chuang a =C3=A9crit :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTGMAC100 Ethernet Media Access Controller supports 10/100/1000 Mbps
> and MII/GMII.  This driver has been working on some ARM/NDS32 SoC's
> including Faraday A369 and Andes AG102.
>=20
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> ---

Did you tried GRO support ?
