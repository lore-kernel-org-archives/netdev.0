From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] tcp: Add tcp_validate_incoming & put
 duplicated code there
Date: Sat, 23 Aug 2008 05:11:17 -0700 (PDT)
Message-ID: <20080823.051117.141240633.davem@davemloft.net>
References: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34498
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbYHWMLT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 08:11:19 -0400
In-Reply-To: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 22 Aug 2008 23:38:27 +0300

> Large block of code duplication removed.
>=20
> Sadly, the return value thing is a bit tricky here but it
> seems the most sensible way to return positive from validator
> on success rather than negative.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
