From: George Anzinger <george@mvista.com>
Subject: Re: [PATCH] Maintainers list update: linux-net -> netdev
Date: Tue, 12 Apr 2005 12:14:56 -0700
Message-ID: <425C1E30.5060405@mvista.com>
References: <20050412062027.GA1614@verge.net.au>
Reply-To: george@mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
        Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
        Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        schwidefsky@de.ibm.com, netdev@oss.sgi.com,
        Mike Phillips <mikep@linuxtr.net>, Philip Blundell <philb@gnu.org>,
        David Dillow <dave@thedillows.org>,
        Paul Gortmaker <p_gortmaker@yahoo.com>,
        Mike McLagan <mike.mclagan@linux.org>,
        Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Jan-Pascal van Best <jvbest@qv3pluto.leidenuniv.nl>,
        Andreas Mohr <100.30936@germany.net>,
        p2@ace.ulyssis.student.kuleuven.ac.be,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Daniele Venzano <venza@brownhat.org>, Jay Schulist <jschlst@samba.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Horms <horms@verge.net.au>
In-Reply-To: <20050412062027.GA1614@verge.net.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Horms wrote:
> On Sat, Apr 09, 2005 at 03:52:05PM +0200, J=F6rn Engel wrote:
>=20
>>On Fri, 8 April 2005 22:16:07 +0200, Pavel Machek wrote:
>>
>>>More importantly, it is still listed as "the list" for network
>>>drivers...
>>>
>>>NETWORK DEVICE DRIVERS
>>>P:      Andrew Morton
>>>M:      akpm@osdl.org
>>>P:      Jeff Garzik
>>>M:      jgarzik@pobox.com
>>>L:      linux-net@vger.kernel.org
>>>S:      Maintained
>>
>>Maybe one of the two maintainers might want to change that? ;)
>=20
>=20
> Use netdev as the mailing list contact instead of the mostly dead
> linux-net list.
>=20
~
>  PHRAM MTD DRIVER
> @@ -1795,7 +1795,7 @@
>  POSIX CLOCKS and TIMERS
>  P:	George Anzinger
>  M:	george@mvista.com
> -L:	linux-net@vger.kernel.org
> +L:	netdev@oss.sgi.com
>  S:	Supported
> =20
I don't really know about the rest of them, but I think this should be:
L: linux-kernel@vger.kernel.org

Least wise that is where I look...
~
--=20
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
