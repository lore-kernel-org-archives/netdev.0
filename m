From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 3/6 v2] net: get rid of multiple
 bond-related netdevice->priv_flags
Date: Wed, 16 Mar 2011 12:52:19 -0700 (PDT)
Message-ID: <20110316.125219.102552093.davem@davemloft.net>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
	<1299935679-18135-4-git-send-email-jpirko@redhat.com>
	<20110316184522.GA15224@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753822Ab1CPTvm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 15:51:42 -0400
In-Reply-To: <20110316184522.GA15224@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 16 Mar 2011 19:45:23 +0100

> Now when bond-related code is moved from net/core/dev.c into bonding
> code, multiple priv_flags are not needed anymore. So let them rot.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied.
