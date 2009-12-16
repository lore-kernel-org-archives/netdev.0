From: David Miller <davem@davemloft.net>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Tue, 15 Dec 2009 21:14:41 -0800 (PST)
Message-ID: <20091215.211441.39161790.davem@davemloft.net>
References: <4B26B09A.7050607@gmail.com>
	<20091215151302.GD5833@nowhere>
	<4B27AF77.7010809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fweisbec@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752760AbZLPFOo@vger.kernel.org>
In-Reply-To: <4B27AF77.7010809@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Dec 2009 16:47:03 +0100

> Le 15/12/2009 16:13, Frederic Weisbecker a =E9crit :
>=20
>> Tested-by: Frederic Weisbecker <fweisbec@gmail.com>
>>=20
>=20
> Thanks for testing Frederic, here is the official patch submission th=
en :)
>=20
>=20
> [PATCH] packet: dont call sleeping functions while holding rcu_read_l=
ock()

Applied, thanks.
