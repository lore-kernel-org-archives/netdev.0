From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kmemcheck annotations
Date: Thu, 29 Oct 2009 22:54:10 -0700 (PDT)
Message-ID: <20091029.225410.265140866.davem@davemloft.net>
References: <4AE96A1D.8050300@gmail.com>
	<20091029.031748.235701096.davem@davemloft.net>
	<4AE97220.3000004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49104
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755738AbZJ3Fxr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 01:53:47 -0400
In-Reply-To: <4AE97220.3000004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Oct 2009 11:44:48 +0100

> David Miller a =E9crit :
>>=20
>> We may be trading size for performance here, I wonder if
>> it's wise to move queue_mapping like that and what
>> locality change we get as a result.
>=20
> I agree, but could not convince me it makes a difference.

Ok, I'll apply your patch as-is to net-2.6, thanks!
