From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 09:34:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415093442.0913486d.rddunlap@osdl.org>
References: <20030414.090610.117741299.davem@redhat.com>
	<20030415.014047.39346510.yoshfuji@linux-ipv6.org>
	<20030414095030.50ad9652.rddunlap@osdl.org>
	<20030415.021728.70559400.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?Q?=B5=C8=C6=A3=B1=D1=CC=C0?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030415.021728.70559400.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Apr 2003 02:17:28 +0900 (JST) YOSHIFUJI Hideaki / =B5=C8=C6=A3=
=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wrote:

| In article <20030414095030.50ad9652.rddunlap@osdl.org> (at Mon, 14 Apr =
2003 09:50:30 -0700), "Randy.Dunlap" <rddunlap@osdl.org> says:
|=20
| > On Tue, 15 Apr 2003 01:40:47 +0900 (JST) YOSHIFUJI Hideaki / =B5=C8=C6=
=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wrote:
| >=20
| > | In article <20030414.090610.117741299.davem@redhat.com> (at Mon, 14=
 Apr 2003 09:06:10 -0700 (PDT)), "David S. Miller" <davem@redhat.com> say=
s:
| > |=20
| > | > So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.
| > | >=20
| > | > Ok?
| > |=20
| > | Okay.  I'd like to see ifIndex in that file, too.
| >=20
| > Yes, sounds good.
| >=20
| > Is this something that you plan to extract from the USAGI Linux 2.4
| > patches and submit for 2.5, or should I continue with my patches?
|=20
| Please let me see your patch in details.
| I'll do it today... (It is 2:00am... I'm sleepy... zzz...)
|=20
| --=20
| Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
| GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA


Hi-

Do you have any updates (recommendations) on how to proceed on this?
Have you looked at my patch file?

I think that we can make some progress without having an answer to
your question about /proc/sys/net/ipv6/conf/foobar file renaming.

Thanks,
--
~Randy
