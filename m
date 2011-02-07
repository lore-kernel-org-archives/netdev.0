From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/5] net: Unified offload configuration
Date: Mon, 07 Feb 2011 14:52:59 -0800 (PST)
Message-ID: <20110207.145259.246536239.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<20110207.133721.48496023.davem@davemloft.net>
	<20110207224937.GA32549@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755056Ab1BGWwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 17:52:24 -0500
In-Reply-To: <20110207224937.GA32549@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 7 Feb 2011 23:49:37 +0100

> What driver did you get this output from?

NIU, which sets NETIF_F_HW_CSUM in netdev->features, which is
absolutely correct.
