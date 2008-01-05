From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-2.6.25 0/4] [NET]: Bloat, bloat and more bloat
Date: Sat, 5 Jan 2008 12:46:08 -0200
Message-ID: <20080105144608.GD12379@ghostprotocols.net>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbYAEOqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 09:46:17 -0500
Content-Disposition: inline
In-Reply-To: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Jan 05, 2008 at 03:39:04PM +0200, Ilpo J=E4rvinen escreveu:
> Hi Dave,
>=20
> After Arnaldo got codiff's inline instrumentation bugs fixed
> (thanks! :-)), I got my .c-inline-bloat-o-meter to power up
> reliably after some tweaking and bug fixing on my behalf...
> It shows some very high readings every now and then in the
> code under net/.

Thank you for the reports and for showing how these tools can be put to
good use!=20

If you have any further suggestions on how to make codiff and the
dwarves to be of more help or find any other bug, please let me know.

- Arnaldo
