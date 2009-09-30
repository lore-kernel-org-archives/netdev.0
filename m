From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: fix mutex imbalance
Date: Wed, 30 Sep 2009 16:41:41 -0700 (PDT)
Message-ID: <20090930.164141.267739667.davem@davemloft.net>
References: <1254208599-1274-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754777AbZI3XlW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 19:41:22 -0400
In-Reply-To: <1254208599-1274-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Tue, 29 Sep 2009 10:16:39 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> port_mutex was unlocked twice.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks!
