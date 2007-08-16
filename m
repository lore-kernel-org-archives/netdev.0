From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6]: Invalid semicolon after if statement
Date: Wed, 15 Aug 2007 17:51:28 -0700 (PDT)
Message-ID: <20070815.175128.82362004.davem@davemloft.net>
References: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi>
	<20070815.150814.82381935.davem@davemloft.net>
	<20070815235219.GA17004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755318AbXHPAva convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 20:51:30 -0400
In-Reply-To: <20070815235219.GA17004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Dave Jones <davej@redhat.com>
Date: Wed, 15 Aug 2007 19:52:20 -0400

> On Wed, Aug 15, 2007 at 03:08:14PM -0700, David Miller wrote:
>  > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
>  > Date: Thu, 16 Aug 2007 00:57:00 +0300 (EEST)
>  >=20
>  > > A similar fix to netfilter from Eric Dumazet inspired me to
>  > > look around a bit by using some grep/sed stuff as looking for
>  > > this kind of bugs seemed easy to automate. This is one of them
>  > > I found where it looks like this semicolon is not valid.
>  > >=20
>  > > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>  >=20
>  > Yikes!  Makes you want to audit the entire tree for these
>  > things :-)))
> =20
> Indeed.  Here's another one.
>=20
> Signed-off-by: Dave Jones <davej@redhat.com>

That got fixed the other day and is the "A similar fix to netfilter
from Eric Dumazet" Ilpo is reffering to above :)
