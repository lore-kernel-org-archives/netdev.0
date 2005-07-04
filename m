From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Mon, 04 Jul 2005 23:39:35 +0200
Message-ID: <42C9AC97.1020902@cosmosbay.com>
References: <42B982D4.9040704@cosmosbay.com>	<1119467012.5325.15.camel@rh4>	<42C9A884.1030906@cosmosbay.com> <20050704.142604.18592223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050704.142604.18592223.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 04 Jul 2005 23:22:12 +0200
>=20
>=20
>>But it seems something is wrong because when network load becomes high =
I get :
>>
>>Jul  4 23:01:19 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
>>Jul  4 23:01:19 dada1 kernel: tg3: eth0: transmit timed out, resetting
>>Jul  4 23:01:24 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
>>Jul  4 23:01:24 dada1 kernel: tg3: eth0: transmit timed out, resetting
>>Jul  4 23:01:29 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
>=20
>=20
> Does this happen without changing the coalescing settings
> at all?
>=20
>=20
Not easy to answer because I have to rebuild a kernel and reboot. Will do=
 that shortly.
