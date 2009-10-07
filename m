From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH netnext-2.6] bonding: fix a parameter name in error
 message
Date: Wed, 07 Oct 2009 14:10:42 -0700 (PDT)
Message-ID: <20091007.141042.260646290.davem@davemloft.net>
References: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752133AbZJGVKr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 17:10:47 -0400
In-Reply-To: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Wed,  7 Oct 2009 22:59:27 +0200

> When parsing module parameters, bond_check_params() erroneously use '=
xor_mode'
> as the name of a module parameter in an error message.
>=20
> The right name for this parameter is 'xmit_hash_policy'.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied.
