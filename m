From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH netnext-2.6] bonding: remove useless assignment
Date: Wed, 07 Oct 2009 14:11:15 -0700 (PDT)
Message-ID: <20091007.141115.101755919.davem@davemloft.net>
References: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
	<1254949168-12404-2-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbZJGVLT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 17:11:19 -0400
In-Reply-To: <1254949168-12404-2-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Wed,  7 Oct 2009 22:59:28 +0200

> The variable old_active is first set to bond->curr_active_slave.
> Then, it is unconditionally set to new_active, without being used in =
between.
>=20
> The first assignment, having no side effect, is useless.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Also applied.

Conclusion, avoid Thunderbird like the plague....
