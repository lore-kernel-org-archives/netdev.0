From: =?ISO-8859-2?Q?Micha=B3_Margula?= <alchemyx@uznam.net.pl>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Thu, 18 Nov 2004 12:27:32 +0100
Message-ID: <419C8724.20006@uznam.net.pl>
References: <20041115122046.1413527e.akpm@osdl.org>	<200411152146.02851.bdschuym@pandora.be> <20041115124843.4c3dd72f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Bart De Schuymer <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041115124843.4c3dd72f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>
>
>Bart De Schuymer <bdschuym@pandora.be> wrote:
> =20
>
>>>Problem is present in 2.6.8.1 and 2.6.9 kernels. There was no such pro=
blem
>>>on 2.4.26.
>>>     =20
>>>
>>Can you do something similar with iptables rules to see if it's specifi=
c to=20
>>ebtables (which I doubt)?
>>   =20
>>
Over 50 hours after converting rules from ebtables to iptables and still=20
no lockup. Everything is fine and I am sure it will go stable for days=20
(as mentioned before lockup with ebtables happens in less than 24 hours).

--=20
Micha=B3 Margula, alchemyx@uznam.net.pl, http://alchemyx.uznam.net.pl/
"W =BFyciu pi=EAkne s=B1 tylko chwile" [Ryszard Riedel]
