From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Mon, 14 Apr 2003 09:50:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030414095030.50ad9652.rddunlap@osdl.org>
References: <20030414080347.0af818f7.rddunlap@osdl.org>
	<20030415.002915.71906095.yoshfuji@linux-ipv6.org>
	<20030414.090610.117741299.davem@redhat.com>
	<20030415.014047.39346510.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?Q?=B5=C8=C6=A3=B1=D1=CC=C0?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030415.014047.39346510.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Apr 2003 01:40:47 +0900 (JST) YOSHIFUJI Hideaki / =B5=C8=C6=A3=
=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wrote:

| In article <20030414.090610.117741299.davem@redhat.com> (at Mon, 14 Apr=
 2003 09:06:10 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:
|=20
| > So we'd then have /proc/net/dev_snmp6/{lo,eth0,eth1} etc.
| >=20
| > Ok?
|=20
| Okay.  I'd like to see ifIndex in that file, too.

Yes, sounds good.

Is this something that you plan to extract from the USAGI Linux 2.4
patches and submit for 2.5, or should I continue with my patches?

Thanks,
--
~Randy
