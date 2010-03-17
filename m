From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Tue, 16 Mar 2010 21:26:59 -0700 (PDT)
Message-ID: <20100316.212659.108927138.davem@davemloft.net>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<4B9FC7F1.5010507@google.com>
	<1268773227.2932.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866Ab0CQE0h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 00:26:37 -0400
In-Reply-To: <1268773227.2932.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Mar 2010 22:00:27 +0100

> Le mardi 16 mars 2010 =E0 11:03 -0700, Tom Herbert a =E9crit :
>> This patch implements software receive side packet steering (RPS).  =
RPS
>> distributes the load of received packet processing across multiple C=
PUs.
 ...
> Well, I tested this on my dev machine, with a vlan over bonding setup=
,
> tg3 and bnx2 drivers (mono queue), and all is good. UDP bench not
> anymore using 100% of one cpu and dropping frames.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
