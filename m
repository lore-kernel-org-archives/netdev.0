From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 15:24:26 -0500 (EST)
Message-ID: <20111202.152426.447759025066188323.davem@davemloft.net>
References: <1322850989.2762.47.camel@edumazet-laptop>
	<20111202.134040.638198723589712419.davem@davemloft.net>
	<1322857369.2762.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab1LBUYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 15:24:32 -0500
In-Reply-To: <1322857369.2762.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 21:22:49 +0100

> Le vendredi 02 d=E9cembre 2011 =E0 13:40 -0500, David Miller a =E9cri=
t :
>=20
>> Yes, for non-SG this always was technically possible.
>>=20
>=20
> Yes this can, I reproduced it very easily.
>=20
> I find this hard to believe...

Grrr :-)

Ok, I'll think about this some more.
