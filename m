From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2-2.6.38 + oif argument error
Date: Thu, 26 Jan 2012 17:16:13 +0100
Message-ID: <1327594573.2500.55.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+h4rtFMtprNyW2GH601TY9gBY1JTWK+Wktka-RzD8MQogK+zQ@mail.gmail.com>
	 <1327521811.2605.8.camel@edumazet-laptop>
	 <CA+h4rtFmfa8=c7xXqcsG7emgnuozMQ2bqgziVMAfr11RHxJnRQ@mail.gmail.com>
	 <1327594401.2500.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, ganeshreddy <ganeshreddy@freescale.com>
To: Ganesh Reddy K <ganeshreddyk@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327594401.2500.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 17:13 +0100, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 26 janvier 2012 =C3=A0 21:30 +0530, Ganesh Reddy K a =C3=A9c=
rit :
> > uname -a output is
> >=20
> > Linux P2020RDB 2.6.32 #32 SMP Tue Dec 6 16:21:38 IST 2011 ppc GNU/L=
inux
>=20
> oif facility was added in 2.6.33 kernel
>=20

If you need to backport this facility, check commit 1b038a5e60
(net 03/05: fib_rules: add oif classification)
