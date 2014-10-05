From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] ematch: Fix early ending of inverted
 containers.
Date: Sat, 04 Oct 2014 20:50:05 -0400 (EDT)
Message-ID: <20141004.205005.829959859421038149.davem@davemloft.net>
References: <542E9505.8010805@cogentembedded.com>
	<20141003134448.GB26399@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ignacy.gawedzki@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaJEAuG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:50:06 -0400
In-Reply-To: <20141003134448.GB26399@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
Date: Fri, 3 Oct 2014 15:44:48 +0200

> The result of a negated container has to be inverted before checking =
for
> early ending.
>=20
> This fixes my previous attempt (17c9c8232663a47f074b7452b9b034efda868=
ca7) to
> make inverted containers work correctly.
>=20
> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>

Applied.
