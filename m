From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] tcp: Make SACK code to split only at mss
 boundaries
Date: Mon, 24 Nov 2008 21:13:58 -0800 (PST)
Message-ID: <20081124.211358.26533289.davem@davemloft.net>
References: <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbYKYFN7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:13:59 -0500
In-Reply-To: <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:01 +0200

> Sadly enough, this adds possible divide though we try to avoid
> it by checking one mss as common case.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
