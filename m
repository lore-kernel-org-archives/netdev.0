From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove useless assignment
Date: Wed, 07 Oct 2009 13:54:36 -0700 (PDT)
Message-ID: <20091007.135436.192028979.davem@davemloft.net>
References: <4ACCF4D5.9050502@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933847AbZJGUyl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 16:54:41 -0400
In-Reply-To: <4ACCF4D5.9050502@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Wed, 07 Oct 2009 22:06:45 +0200

> Resent after fixing tab to space corruption.

It's still breaking up long lines, two examples:

> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
=2E..

> @@ -1084,7 +1084,7 @@ static struct slave *bond_find_best_slave(struc=
t
> bonding *bond)

Please fix this and resubmit.
