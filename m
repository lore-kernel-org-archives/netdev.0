From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 15:49:32 -0700 (PDT)
Message-ID: <20100416.154932.147279343.davem@davemloft.net>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	<20100415.233334.242114544.davem@davemloft.net>
	<1271446679.16881.4298.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932669Ab0DPWt3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Apr 2010 18:49:29 -0400
In-Reply-To: <1271446679.16881.4298.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Apr 2010 21:37:59 +0200

> Le jeudi 15 avril 2010 =E0 23:33 -0700, David Miller a =E9crit :
>> From: Tom Herbert <therbert@google.com>
>> Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)
>>=20
>> > Version 5 of RFS:
>> > - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as a
>> > static function.
>> > - Apply limits to rps_sock_flow_entires systcl and rps_flow_count
>> > sysfs variable.
>>=20
>> I've read this over a few times and I think it's ready to go into
>> net-next-2.6, we can tweak things as-needed from here on out.
>>=20
>> Eric, what do you think?
>=20
> I think I can give my Sob, and we have time to fully test it and twea=
k
> it if necessary.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Great, I'll add this to net-next-2.6 right now.

Thanks!
