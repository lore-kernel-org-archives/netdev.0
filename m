From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Wed, 02 Feb 2011 19:34:28 -0800 (PST)
Message-ID: <20110202.193428.193705695.davem@davemloft.net>
References: <20110202.170750.229739784.davem@davemloft.net>
	<1296698023.4434.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752127Ab1BCDdx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 22:33:53 -0500
In-Reply-To: <1296698023.4434.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Feb 2011 02:53:43 +0100

> Le mercredi 02 f=E9vrier 2011 =E0 17:07 -0800, David Miller a =E9crit=
 :
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>=20
>=20
> Hmm, you forgot a Changelog David ;)

Maybe, or maybe not, frankly it's quite self-evident if you ask
me. :-)

