From: David Miller <davem@davemloft.net>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 04 Dec 2008 09:56:29 -0800 (PST)
Message-ID: <20081204.095629.84195633.davem@davemloft.net>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	<Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
	<b98e548c0812040726w6ac94d66x8d9f2b1b4aaf7068@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: saverio.mascolo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751884AbYLDR43 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 12:56:29 -0500
In-Reply-To: <b98e548c0812040726w6ac94d66x8d9f2b1b4aaf7068@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Date: Thu, 4 Dec 2008 16:26:30 +0100

> On Thu, Dec 4, 2008 at 1:41 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsin=
ki.fi> wrote:
> > On Wed, 3 Dec 2008, Saverio Mascolo wrote:
> >
> >> we have added plots of cwnd at
> >>
> >> http://c3lab.poliba.it/index.php/TCP_over_Hsdpa
> >>
> >> in the case of newreno, wetwood+, bic/cubic.
> >
> > You lack the most important detail, ie., the used kernel versions!
>=20
> 2.6

There are many different "2.6" kernels, which one in particular?
