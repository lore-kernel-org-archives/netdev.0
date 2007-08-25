From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] [TCP]: Rename tcp_ack_packets_out -> tcp_rearm_rto
Date: Fri, 24 Aug 2007 22:53:35 -0700 (PDT)
Message-ID: <20070824.225335.94895034.davem@davemloft.net>
References: <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
	<118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52342
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755902AbXHYFxg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 01:53:36 -0400
In-Reply-To: <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 20 Aug 2007 16:16:31 +0300

> Only thing that tiny function does is rearming the RTO (if
> necessary), name it accordingly.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
