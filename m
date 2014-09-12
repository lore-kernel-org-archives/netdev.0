From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "ipv4: Clarify in docs that
 accept_local requires rp_filter."
Date: Fri, 12 Sep 2014 16:34:59 -0400 (EDT)
Message-ID: <20140912.163459.2171012184695188640.davem@davemloft.net>
References: <1410366023-9129-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org, gregory.detal@uclouvain.be,
	christoph.paasch@uclouvain.be, hannes@redhat.com,
	sergei.shtylyov@cogentembedded.com
To: sebastien.barre@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaILUfH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:35:07 -0400
In-Reply-To: <1410366023-9129-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>
Date: Wed, 10 Sep 2014 18:20:23 +0200

> This reverts commit c801e3cc1925 ("ipv4: Clarify in docs that accept_=
local requires rp_filter.").
> It is not needed anymore since commit 1dced6a85482 ("ipv4: Restore ac=
cept_local behaviour in fib_validate_source()").
>=20
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Cc: Gregory Detal <gregory.detal@uclouvain.be>
> Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>

Applied, thanks.
