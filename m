From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] Phonet: allocate separate ARP type for GPRS over a
 Phonet pipe
Date: Wed, 17 Dec 2008 15:52:53 -0800 (PST)
Message-ID: <20081217.155253.11520602.davem@davemloft.net>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
	<1229522874-20636-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752211AbYLQXwv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 18:52:51 -0500
In-Reply-To: <1229522874-20636-2-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 17 Dec 2008 16:07:51 +0200

> A separate xmit lock class supports GPRS over a Phonet pipe over a TU=
N
> device (type ARPHRD_NONE).
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
