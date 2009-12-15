From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Tue, 15 Dec 2009 09:45:54 +0100
Message-ID: <4B274CC2.9030706@gmail.com>
References: <20091214.111638.165984790.davem@davemloft.net>	<4B2690B4.3030604@gmail.com>	<20091214.143522.102450157.davem@davemloft.net> <20091214.231840.106434922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757445AbZLOIqG@vger.kernel.org>
In-Reply-To: <20091214.231840.106434922.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 15/12/2009 08:18, David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Mon, 14 Dec 2009 14:35:22 -0800 (PST)
>=20
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 14 Dec 2009 20:23:32 +0100
>>
>>> If you disable syncookies, I presume you dont have warnings ?
>>
>> It happens even with syncookies disabled, hmmm...
>=20
> FWIW, I'm starting to bisect this.


OK, I took a look at commit 05eaade2782fb0c90d3034fd7a7d5a16266182bb,
but I have no more time today for kernel dev, sorry :(
