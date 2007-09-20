From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] [TCP]: Cleanup tcp_tso_acked and
 tcp_clean_rtx_queue
Date: Thu, 20 Sep 2007 11:33:53 -0700 (PDT)
Message-ID: <20070920.113353.82696899.davem@davemloft.net>
References: <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755144AbXITSdx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:33:53 -0400
In-Reply-To: <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:48 +0300

> Implements following cleanups:
> - Comment re-placement (CodingStyle)
> - tcp_tso_acked() local (wrapper-like) variable removal
>   (readability)
> - __-types removed (IMHO they make local variables jumpy looking
>   and just was space)
> - acked -> flag (naming conventions elsewhere in TCP code)
> - linebreak adjustments (readability)
> - nested if()s combined (reduced indentation)
> - clarifying newlines added
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
