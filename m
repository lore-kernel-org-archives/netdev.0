From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 02:17:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415.021728.70559400.yoshfuji@linux-ipv6.org>
References: <20030414.090610.117741299.davem@redhat.com>
	<20030415.014047.39346510.yoshfuji@linux-ipv6.org>
	<20030414095030.50ad9652.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org
In-Reply-To: <20030414095030.50ad9652.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030414095030.50ad9652.rddunlap@osdl.org> (at Mon, 14 Apr 20=
03 09:50:30 -0700), "Randy.Dunlap" <rddunlap@osdl.org> says:

> On Tue, 15 Apr 2003 01:40:47 +0900 (JST) YOSHIFUJI Hideaki / =B5=C8=C6=A3=
=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wrote:
>=20
> | In article <20030414.090610.117741299.davem@redhat.com> (at Mon, 14 A=
pr 2003 09:06:10 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:
> |=20
> | > So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.
> | >=20
> | > Ok?
> |=20
> | Okay.  I'd like to see ifIndex in that file, too.
>=20
> Yes, sounds good.
>=20
> Is this something that you plan to extract from the USAGI Linux 2.4
> patches and submit for 2.5, or should I continue with my patches?

Please let me see your patch in details.
I'll do it today... (It is 2:00am... I'm sleepy... zzz...)

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
