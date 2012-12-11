From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iproute2: ss - change default filter to include all
 socket types
Date: Tue, 11 Dec 2012 12:45:13 -0500 (EST)
Message-ID: <20121211.124513.1852652348476771399.davem@davemloft.net>
References: <1355244172-32071-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: contyk@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab2LKRpO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 12:45:14 -0500
In-Reply-To: <1355244172-32071-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Petr =A6abata <contyk@redhat.com>
Date: Tue, 11 Dec 2012 17:42:52 +0100

> Currently the default filter lists TCP sockets only which is
> rather confusing especially when the '-a/--all' flag is used.
> This patch changes the default to include all sockets, imitating
> netstat(8) behavior.
>=20
> Signed-off-by: Petr =A6abata <contyk@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
