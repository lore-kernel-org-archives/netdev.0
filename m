From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 21:40:52 -0700 (PDT)
Message-ID: <20080725.214052.164701602.davem@davemloft.net>
References: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751182AbYGZEkx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 00:40:53 -0400
In-Reply-To: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 25 Jul 2008 15:46:58 +0300

> Removes legacy reinvent-the-wheel type thing. The generic
> machinery integrates much better to automated debugging aids
> such as kerneloops.org (and others), and is unambiguous due to
> better naming. Non-intuively BUG_TRAP() is actually equal to
> WARN_ON() rather than BUG_ON().
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
