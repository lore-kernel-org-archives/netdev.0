From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 11:49:51 -0700 (PDT)
Message-ID: <20101028.114951.59674318.davem@davemloft.net>
References: <1288291138.2711.0.camel@edumazet-laptop>
	<20101028.114102.112602886.davem@davemloft.net>
	<1288291679.2711.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51587
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934001Ab0J1St2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 14:49:28 -0400
In-Reply-To: <1288291679.2711.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Oct 2010 20:47:59 +0200

> Le jeudi 28 octobre 2010 =E0 11:41 -0700, David Miller a =E9crit :
>> I am still able to revert this I think without screwing up
>> publicly visible history, so I will double check and do the
>> revert if I can.
>=20
> Cool, I'll provide a patch in a couple of minutes, when tested.

Thanks.
