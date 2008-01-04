From: David Miller <davem@davemloft.net>
Subject: Re: [ICMP]: Avoid sparse warnings in net/ipv4/icmp.c
Date: Fri, 04 Jan 2008 00:51:57 -0800 (PST)
Message-ID: <20080104.005157.45599323.davem@davemloft.net>
References: <477DC304.40508@cosmosbay.com>
	<20080103.212610.263261100.davem@davemloft.net>
	<477DC564.4050008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754692AbYADIv6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 03:51:58 -0500
In-Reply-To: <477DC564.4050008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 04 Jan 2008 06:34:28 +0100

> David Miller a =E9crit :
> > Please use "inline" instead of "__inline__".  If other stuff
> > uses __inline__ in that file, feel free to fix it up too.
>=20
> You are right, here is the updated version

Applied, thanks Eric.
