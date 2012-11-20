From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Tue, 20 Nov 2012 03:34:05 -0500 (EST)
Message-ID: <20121120.033405.490869980095149376.davem@davemloft.net>
References: <50A66DD3.20807@6wind.com>
	<20121119.190753.856116050444408241.davem@davemloft.net>
	<50AB3F99.7070701@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab2KTIeH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 03:34:07 -0500
In-Reply-To: <50AB3F99.7070701@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Nov 2012 09:30:17 +0100

> Le 20/11/2012 01:07, David Miller a =E9crit :
>> Why not put this aside and submit the other parts of your
>> patch set on their own, since those looked fine to me?
> Ok, no problem. I wanted to get feedback about this kind of idea, I
> understand the point.
>=20
> When you said "the other parts", you mean only patch 2/4 (sit: allow
> to configure 6rd tunnels via netlink) or 3/4 and 4/4 too?
> Because 3/4 and 4/4 are equivalent to this one.

I meant patch #2.
