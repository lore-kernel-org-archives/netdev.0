From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Thu, 01 Oct 2009 15:17:08 -0700 (PDT)
Message-ID: <20091001.151708.199560959.davem@davemloft.net>
References: <1254413613.665110.11357.nullmailer@tron.codefidence.com>
	<4AC4E4E1.5010300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gilad@codefidence.com, netdev@vger.kernel.org, ori@comsleep.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752235AbZJAWQt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 18:16:49 -0400
In-Reply-To: <4AC4E4E1.5010300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2009 19:20:33 +0200

> Gilad Ben-Yossef a =E9crit :
>> From: Ori Finkelman <ori@comsleep.com>
>>=20
>> Acknowledge TCP window scale support by inserting the proper option =
in SYN/ACK=20
>> and SYN headers even if our window scale is zero.
 ...
>> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
>> Signed-off-by: Ori Finkelman <ori@comsleep.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
