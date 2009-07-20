From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix error return for setsockopt(SO_TIMESTAMPING)
Date: Mon, 20 Jul 2009 08:24:15 -0700 (PDT)
Message-ID: <20090720.082415.107911731.davem@davemloft.net>
References: <1248086824-18836-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbZGTPYK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 11:24:10 -0400
In-Reply-To: <1248086824-18836-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Mon, 20 Jul 2009 13:47:04 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> I guess it should be -EINVAL rather than EINVAL. I have not checked
> when the bug came in. Perhaps a candidate for -stable?
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
