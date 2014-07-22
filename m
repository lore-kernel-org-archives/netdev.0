From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Tue, 22 Jul 2014 20:20:04 -0300
Message-ID: <20140722232004.GA7838@arch.cereza>
References: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140721.202749.913689946944612851.davem@davemloft.net>
 <20140722144519.GA682@arch.cereza>
 <20140722.131639.1180592286226896307.davem@davemloft.net>
 <20140723002916.67a0bb3c@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jason@lakedaemon.net, mw@semihalf.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com
To: David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:37209 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756817AbaGVXVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 19:21:04 -0400
Content-Disposition: inline
In-Reply-To: <20140723002916.67a0bb3c@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 Jul 12:29 AM, Thomas Petazzoni wrote:
> On Tue, 22 Jul 2014 13:16:39 -0700 (PDT), David Miller wrote:
>=20
> > >> This series does not apply to the 'net' tree at all, please resp=
in
> > >> and resubmit.
> > >=20
> > > This series applies on net-next.
> > >=20
> > > Sorry for not mentioning it,
> >=20
> > They are bonafide bug fixes, therefore should be targetted at 'net'=
=2E
>=20
> Except that I believe they are fixes for a driver which itself is in
> net-next, i.e scheduled for 3.17.
>=20

That's right. These are fixes for the new mvpp2 driver, which is only
in net-next.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
