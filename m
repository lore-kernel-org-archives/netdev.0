From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove useless assignment
Date: Wed, 07 Oct 2009 01:05:14 -0700 (PDT)
Message-ID: <20091007.010514.158756054.davem@davemloft.net>
References: <4AB67242.6060803@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751109AbZJGIFU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 04:05:20 -0400
In-Reply-To: <4AB67242.6060803@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Sun, 20 Sep 2009 20:19:46 +0200

> The variable old_active is first set to bond->curr_active_slave.
> Then, it is unconditionally set to new_active, without being used in
> between.
>=20
> The first assignment, having no side effect, is useless.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Nicolas, all of your patches are corrupts by your email client.
It breaks up long lines and transforms tab characters into spaces.

Please correct this, and resubmit all of your pending patches.

Thank you.
