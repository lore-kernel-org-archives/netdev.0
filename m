From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ematch: Fix matching of inverted containers.
Date: Mon, 29 Sep 2014 15:31:40 -0400 (EDT)
Message-ID: <20140929.153140.1435317012335379052.davem@davemloft.net>
References: <20140924163839.GA6925@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ignacy.gawedzki@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaI2Tbm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:31:42 -0400
In-Reply-To: <20140924163839.GA6925@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
Date: Wed, 24 Sep 2014 18:38:39 +0200

> Negated expressions and sub-expressions need to have their flags chec=
ked for
> TCF_EM_INVERT and their result negated accordingly.
>=20
> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>

Applied, thank you.
