From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Separate lost_retrans loop into own function
Date: Wed, 10 Oct 2007 02:45:56 -0700 (PDT)
Message-ID: <20071010.024556.11386242.davem@davemloft.net>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753982AbXJJJpx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:45:53 -0400
In-Reply-To: <11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue,  9 Oct 2007 15:20:00 +0300

> Follows own function for each task principle, this is really
> somewhat separate task being done in sacktag. Also reduces
> indentation.
>=20
> In addition, added ack_seq local var to break some long
> lines & fixed coding style things.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo!
