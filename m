From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 19:45:08 +0100
Message-ID: <1300992308.3747.205.camel@edumazet-laptop>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	 <1300980118.3747.42.camel@edumazet-laptop>
	 <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	 <1300983340.3747.44.camel@edumazet-laptop>
	 <1300986084.3747.101.camel@edumazet-laptop>
	 <AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 mars 2011 =C3=A0 19:14 +0100, Alessandro Suardi a =C3=A9cri=
t :

>=20
> I will however make one more bug report, as vpnc is broken before
>  and after this patch - have to dig out what vpnc-script tries to do,
>  which results in
>=20
> Error: either "to" is duplicate, or "ipid" is a garbage.
>=20
>  after establishing the VPN tunnel.
>=20

try following patch

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
it;h=3D406b6f974dae76a5b795d5c251d11c979a4e509b
