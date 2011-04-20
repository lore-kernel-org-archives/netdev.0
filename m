From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s390: convert to hw_features
Date: Wed, 20 Apr 2011 01:31:38 -0700 (PDT)
Message-ID: <20110420.013138.39192305.davem@davemloft.net>
References: <20110419104320.314AB13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	linux-s390@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808Ab1DTIcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:32:13 -0400
In-Reply-To: <20110419104320.314AB13A66@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)

> options.large_send was easy to get rid of. options.checksum_type has =
deeper
> roots so is left for later cleanup.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
