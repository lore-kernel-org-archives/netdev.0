From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: make ipv6 PKTINFO honour freebind
Date: Tue, 08 Nov 2011 15:17:23 -0500 (EST)
Message-ID: <20111108.151723.247202724374183504.davem@davemloft.net>
References: <CAHo-Oow3LhhvMEO8ph7ZM2TO48KtTak+VZjY56ceWdhxeyUzgA@mail.gmail.com>
	<1320713842-21152-2-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143Ab1KHUR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 15:17:27 -0500
In-Reply-To: <1320713842-21152-2-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon,  7 Nov 2011 16:57:22 -0800

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> This just makes it possible to spoof source IPv6 address on a socket
> without having to create and bind a new socket for every source IP
> we wish to spoof.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Applied.
