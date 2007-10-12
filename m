From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [TCP]: Extract tcp_match_queue_to_sack from
 sacktag code
Date: Thu, 11 Oct 2007 17:34:35 -0700 (PDT)
Message-ID: <20071011.173435.131925050.davem@davemloft.net>
References: <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51167
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753417AbXJLAec convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:34:32 -0400
In-Reply-To: <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:04 +0300

> This is necessary for upcoming DSACK bugfix. Reduces sacktag
> length which is not very sad thing at all... :-)
>=20
> Notice that there's a need to handle out-of-mem at caller's
> place.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
