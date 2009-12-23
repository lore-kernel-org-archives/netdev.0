From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 Ver2] tcp: Remove unrequired operations in
 tcp_push()
Date: Wed, 23 Dec 2009 14:15:59 -0800 (PST)
Message-ID: <20091223.141559.183052897.davem@davemloft.net>
References: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757324AbZLWWP5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 17:15:57 -0500
In-Reply-To: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 10 Dec 2009 22:46:52 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Remove unrequired operations in tcp_push()
>=20
> Changelog:
> 	Removed a temporary skb variable from tcp_push()
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
