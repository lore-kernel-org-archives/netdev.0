From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atl*: convert to hw_features
Date: Thu, 07 Apr 2011 20:19:09 -0700 (PDT)
Message-ID: <20110407.201909.112607358.davem@davemloft.net>
References: <20110407173218.1532213909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com,
	jie.yang@atheros.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36123
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757411Ab1DHDTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:19:45 -0400
In-Reply-To: <20110407173218.1532213909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  7 Apr 2011 19:32:18 +0200 (CEST)

> Things left as they were:
>  - atl1: is RX checksum really enabled?
>  - atl2: copy-paste from atl1, with-errors-on-modify I presume
>  - atl1c: there's a bug: MTU can't be changed if device is not up
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
