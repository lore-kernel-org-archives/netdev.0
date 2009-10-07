From: David Miller <davem@davemloft.net>
Subject: Re: [RFC take2] pkt_sched: gen_estimator: Dont report fake rate
 estimators
Date: Wed, 07 Oct 2009 01:27:51 -0700 (PDT)
Message-ID: <20091007.012751.134629837.davem@davemloft.net>
References: <4AC5F46B.6030308@gmail.com>
	<4AC65E6F.8050403@gmail.com>
	<4AC66352.8050500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757719AbZJGI14 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 04:27:56 -0400
In-Reply-To: <4AC66352.8050500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Oct 2009 22:32:18 +0200

> Jarek Poplawski a =E9crit :
>>=20
>>=20
>> Hmm... So you made me to do some "real" work here, and guess what?:
>> there is one serious checkpatch warning! ;-) Plus, this new paramete=
r
>> should be added to the function description. Otherwise:
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>>=20
>> Thanks,
>> Jarek P.
>>=20
>> PS: I guess full "Don't" would show we really mean it...
>=20
> Okay :) Here is the last round, before the night !
>=20
> Thanks again
>=20
>=20
> [RFC] pkt_sched: gen_estimator: Don't report fake rate estimators

Applied, thanks!
