From: David Miller <davem@davemloft.net>
Subject: Re: network device reference leak with net-next
Date: Mon, 15 Nov 2010 18:06:41 -0800 (PST)
Message-ID: <20101115.180641.183062383.davem@davemloft.net>
References: <20101115111024.3b3377be@nehalam>
	<4CE1BFCE.70105@intel.com>
	<1289863543.3364.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	lorenzo@google.com, netdev@vger.kernel.org, brian.haley@hp.com,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43080
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755178Ab0KPCGQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 21:06:16 -0500
In-Reply-To: <1289863543.3364.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Nov 2010 00:25:43 +0100

> Le lundi 15 novembre 2010 =E0 15:18 -0800, John Fastabend a =E9crit :
>> With a quick hack the above seems to resolve the issue but I'll need=
 to review the ipv6 stuff to be sure this is sane.
>>=20
>> Thanks,
>> John.
>=20
> Your machine is faster than mine ;)
>=20
> Yes this commit seems buggy, thanks for finding the problem !

Indeed, thanks John.  Please send a final fix after you've done
your review.

Thanks again!
