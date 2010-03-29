From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 19:45:17 +0200
Message-ID: <1269884717.1958.2.camel@edumazet-laptop>
References: <4BB09021.6020202@petalogix.com>
	 <1269864994.2164.21.camel@edumazet-laptop> <4BB0BF28.5090505@petalogix.com>
	 <4BB0C6E1.2090606@petalogix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: michal.simek@petalogix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB0C6E1.2090606@petalogix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 mars 2010 =C3=A0 17:27 +0200, Michal Simek a =C3=A9crit :
> Michal Simek wrote:
> > Eric Dumazet wrote:
> >> Le lundi 29 mars 2010 =C3=A0 13:33 +0200, Michal Simek a =C3=A9cri=
t :
> >>
> >>> Do you have any idea howto improve TCP/UDP performance in general=
?
> >>> Or tests which can point me on weak places.
> >>
> >> Could you post "netstat -s" on your receiver, after fresh boot and=
 your
> >> iperf session, for 32 MB and 256 MB ram case ?
> >>
> >=20
> > I am not sure if is helpful but look below.
> >=20
> Sorry I forget to c&p that second part. :-(
>=20

Sorry, your netstat is not up2date.

If you cannot correct it to last version
[ net-tools 1.60 , netstat 1.42 ], please send

cat /proc/net/snmp
cat /proc/net/netstat
