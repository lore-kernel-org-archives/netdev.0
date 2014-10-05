From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Removed unused inet6 address state
Date: Sat, 04 Oct 2014 20:37:29 -0400 (EDT)
Message-ID: <20141004.203729.2000611501192175253.davem@davemloft.net>
References: <1412277322-27823-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be,
	herbert@gondor.apana.org.au
To: sebastien.barre@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAhb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:37:31 -0400
In-Reply-To: <1412277322-27823-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>
Date: Thu, 2 Oct 2014 21:15:22 +0200

> the inet6 state INET6_IFADDR_STATE_UP only appeared in its definition=
=2E
>=20
> Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>

Looks good, applied.
