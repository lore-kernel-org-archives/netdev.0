From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.24 0/5]: TCP sacktag cache usage recoded
Date: Wed, 10 Oct 2007 02:58:29 -0700 (PDT)
Message-ID: <20071010.025829.106434530.davem@davemloft.net>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, sangtae.ha@gmail.com,
	virtualphtn@gmail.com, baruch@ev-en.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754322AbXJJJ60 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:58:26 -0400
In-Reply-To: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Sep 2007 13:28:42 +0300

> After couple of wrong-wayed before/after()s and one infinite
> loopy version, here's the current trial version of a sacktag =20
> cache usage recode....
>=20
> Two first patches come from tcp-2.6 (rebased and rotated).
> This series apply cleanly only on top of the other three patch
> series I posted earlier today. The last debug patch provides
> some statistics for those interested enough.
>=20
> Dave, please DO NOT apply! ...Some thoughts could be nice
> though :-).

Ilpo, I have not forgotten about this patch set.

It is something I plan to look over after the madness of merging
net-2.6.24 to Linus is complete.
