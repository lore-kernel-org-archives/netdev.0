From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 03 Feb 2011 02:53:43 +0100
Message-ID: <1296698023.4434.3.camel@edumazet-laptop>
References: <20110202.170750.229739784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50758 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab1BCBxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 20:53:52 -0500
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 17:07 -0800, David Miller a =C3=
=A9crit :
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20

Hmm, you forgot a Changelog David ;)

I thought Tom and Google guys were preparing a nice one ?



