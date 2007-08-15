From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6]: Invalid semicolon after if statement
Date: Wed, 15 Aug 2007 15:08:14 -0700 (PDT)
Message-ID: <20070815.150814.82381935.davem@davemloft.net>
References: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758459AbXHOWIR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 18:08:17 -0400
In-Reply-To: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 16 Aug 2007 00:57:00 +0300 (EEST)

> A similar fix to netfilter from Eric Dumazet inspired me to
> look around a bit by using some grep/sed stuff as looking for
> this kind of bugs seemed easy to automate. This is one of them
> I found where it looks like this semicolon is not valid.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Yikes!  Makes you want to audit the entire tree for these
things :-)))

Patch applied, thanks a lot Ilpo!
