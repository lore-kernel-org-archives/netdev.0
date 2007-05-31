From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] [TCP]: Move code from tcp_ecn.h to tcp*.c and
 tcp.h & remove it
Date: Thu, 31 May 2007 01:43:16 -0700 (PDT)
Message-ID: <20070531.014316.112848881.davem@davemloft.net>
References: <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759285AbXEaInC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 04:43:02 -0400
In-Reply-To: <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:35:58 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> No other users exist for tcp_ecn.h. Very few things remain in
> tcp.h, for most TCP ECN functions callers reside within a
> single .c file and can be placed there.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, applied.
