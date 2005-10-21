From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] forcedeth: add support for interrupt mitigation
Date: Fri, 21 Oct 2005 22:29:08 +0200
Message-ID: <20051021202908.GA18966@electric-eye.fr.zoreil.com>
References: <43592FE5.20106@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <43592FE5.20106@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul <manfred@colorfullife.com> :
> The current forcedeth driver doesn't support interrupt mitigation, this=
=20
> can result in an incredible number of interrupts/sec for gigabit links.=
=20
> The attached patch adds a throughput mode that enables an interrupt=20
> mitigation scheme.

Na=EFve question: what about the NAPI way ?

--
Ueimor
