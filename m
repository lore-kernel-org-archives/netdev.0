From: David Miller <davem@davemloft.net>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 04 Dec 2008 09:57:29 -0800 (PST)
Message-ID: <20081204.095729.120474403.davem@davemloft.net>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	<Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
	<b98e548c0812040726w6ac94d66x8d9f2b1b4aaf7068@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: saverio.mascolo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbYLDR52 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 12:57:28 -0500
In-Reply-To: <b98e548c0812040726w6ac94d66x8d9f2b1b4aaf7068@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Date: Thu, 4 Dec 2008 16:26:30 +0100

> On Thu, Dec 4, 2008 at 1:41 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsin=
ki.fi> wrote:
> >And
> > also information if some sysctls were tuned or not. This is especia=
lly
> > important since you seem to claim that bic is the default which it =
hasn't
> > been for years?!
>=20
> bic is default since a couple of years, at my by knoweledge. btw now =
it is.

Currently cubic is the default, and it has been for some
time now.
