From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] qeth: use ndo_set_features callback for initial
 setup and recovery
Date: Wed, 18 May 2011 17:27:50 -0400 (EDT)
Message-ID: <20110518.172750.437310904272663239.davem@davemloft.net>
References: <20110518132834.728225299@de.ibm.com>
	<20110518132905.064355130@de.ibm.com>
	<BANLkTik3A8zdDODnSntYZs8sfBvdtLGrOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: frank.blaschka@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743Ab1ERV2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 17:28:03 -0400
In-Reply-To: <BANLkTik3A8zdDODnSntYZs8sfBvdtLGrOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Wed, 18 May 2011 15:43:11 +0200

> 2011/5/18  <frank.blaschka@de.ibm.com>:
>> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>>
>> This patch uses the ndo_set_features callback during normal device
>> startup or recovery to turn on hardware RX checksum. Patch was done
>> with much help from Michal Miroslaw, thx!!!
>>
>> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
>=20
> [regarding usage of ndo_set_features and friends]
> Reviewed-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied, thanks.
