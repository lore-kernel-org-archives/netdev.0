From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: reimplement softnet_data.output_queue as a
 FIFO queue
Date: Tue, 27 Apr 2010 14:32:24 -0700 (PDT)
Message-ID: <20100427.143224.90800699.davem@davemloft.net>
References: <1272359184-2929-1-git-send-email-xiaosuo@gmail.com>
	<1272400618.2343.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33666
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0VcS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 17:32:18 -0400
In-Reply-To: <1272400618.2343.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Apr 2010 22:36:58 +0200

> Le mardi 27 avril 2010 =E0 17:06 +0800, Changli Gao a =E9crit :
>> reimplement softnet_data.output_queue as a FIFO queue.
>>=20
>> reimplement softnet_data.output_queue as a FIFO queue to keep the fa=
irness among
>> the qdiscs rescheduled.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
