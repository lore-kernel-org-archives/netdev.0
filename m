From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Thu, 19 Apr 2007 14:42:45 -0700
Message-ID: <20070419144245.2a0a0905.akpm@linux-foundation.org>
References: <461D26CB.3010508@trash.net>
	<1176400428.24446.40.camel@nt.wq.cz>
	<4623029A.2090906@trash.net>
	<20070416.171016.43503207.davem@davemloft.net>
	<4624C46D.1030609@trash.net>
	<1176900487.8348.36.camel@nt.wq.cz>
	<462625E4.8030802@trash.net>
	<1176982238.5032.22.camel@nt.wq.cz>
	<46275CA3.1070503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Milan =?ISO-8859-1?Q?Koci=E1n?= <milon@wq.cz>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55844 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767003AbXDSVnG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 17:43:06 -0400
In-Reply-To: <46275CA3.1070503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Apr 2007 14:12:19 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Milan Koci=E1n wrote:
> > ok, here is new version. Sign is in patch. Is it correct?
> >=20
> > --- a/net/ipv4/fib_hash.c	2007-04-18 12:50:11.000000000 +0200
> > +++ b/net/ipv4/fib_hash.c	2007-04-19 10:21:04.267136960 +0200
> > [...]
> > Signed-off-by: Milan Kocian <milon@wq.cz>
>=20
>=20
> Looks good, thanks.
>=20
> Acked-by: Patrick McHardy <kaber@trash.net>

Can we please have a final version of this with appropriate Subject:
and complete changelogging?

Thanks.
