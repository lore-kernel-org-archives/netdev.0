From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2-2.6.38 + oif argument error
Date: Wed, 25 Jan 2012 21:03:31 +0100
Message-ID: <1327521811.2605.8.camel@edumazet-laptop>
References: <CA+h4rtFMtprNyW2GH601TY9gBY1JTWK+Wktka-RzD8MQogK+zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, ganeshreddy <ganeshreddy@freescale.com>
To: Ganesh Reddy K <ganeshreddyk@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+h4rtFMtprNyW2GH601TY9gBY1JTWK+Wktka-RzD8MQogK+zQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 01:14 +0530, Ganesh Reddy K a =C3=A9cri=
t :
> Hello,
>=20
> I am trying to exercise 'ip rules'  command with some configuration o=
n
>  a PowerPC Processor. Version is iproute2-2.6.38
>=20
>=20
> I tried "ip rule add oif eth1 table 100"
> It  resulted with  error message "RTNETLINK answers: Invalid argument=
".
>=20
> Can anybody tried this.
>=20
> It is shown in the ip rule help all the possible options . Few of the=
m
> are iif, oif.    iif option is working . No issue observed.   oif
> option is causing error.
>=20
>=20
> Can you please share any patch fixes to proceed further ?
>=20

What is your kernel version ?
