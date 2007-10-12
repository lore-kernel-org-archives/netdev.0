From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to
 work-to-do cases
Date: Thu, 11 Oct 2007 17:36:22 -0700 (PDT)
Message-ID: <20071011.173622.09942622.davem@davemloft.net>
References: <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753471AbXJLAgU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:36:20 -0400
In-Reply-To: <1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:07 +0300

> This addition of lost_retrans_low to tcp_sock might be
> unnecessary, it's not clear how often lost_retrans worker is
> executed when there wasn't work to do.
>=20
> Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
