From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Tue, 05 Jul 2005 00:55:37 +0200
Message-ID: <42C9BE69.2070008@cosmosbay.com>
References: <20050704.142604.18592223.davem@davemloft.net>	<42C9AC97.1020902@cosmosbay.com>	<42C9B8DB.7020403@cosmosbay.com> <20050704.154712.63128211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050704.154712.63128211.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :

> Please don't ever do stuff like that :-(  That makes the driver
> version, and any other information you report completely meaningless
> and useless.  You've just wasted a lot of our time.
>=20

Yes. But if you dont want us to test your patches, dont send them to the =
list.

For your information, 2.6.13-rc1 locks too.

Very easy way to lock it :

ping -f some_destination.



> I have no idea to even know _WHICH_ IRQ spinlock patch you applied.
>=20
> The one that ended up in Linus's tree has many bug fixes and
> refinements.  The ones which were posted on netdev had many bugs and
> deadlocks which needed to be cured before pushing the change upstream.
>=20
>=20
