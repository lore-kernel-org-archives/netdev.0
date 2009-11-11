From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] CAN: use dev_get_by_index_rcu
Date: Tue, 10 Nov 2009 22:50:26 -0800 (PST)
Message-ID: <20091110.225026.79895551.davem@davemloft.net>
References: <20091110175647.824581805@vyatta.com>
	<4AF9B21E.50805@gmail.com>
	<4AFA5190.60600@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753377AbZKKGt7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:49:59 -0500
In-Reply-To: <4AFA5190.60600@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Hartkopp <oliver@hartkopp.net>
Date: Wed, 11 Nov 2009 06:54:24 +0100

> Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>> Use new function to avoid doing read_lock().
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
=2E..
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>=20
> Thanks everyone!
>=20
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied.
