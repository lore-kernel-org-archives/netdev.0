From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: 2013-08-17b
Date: Tue, 20 Aug 2013 16:58:05 -0700 (PDT)
Message-ID: <20130820.165805.1328306127818071916.davem@davemloft.net>
References: <1376737486-1863-1-git-send-email-ordex@autistici.org>
	<20130820.165649.385314778551035966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab3HTX6G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 19:58:06 -0400
In-Reply-To: <20130820.165649.385314778551035966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Tue, 20 Aug 2013 16:56:49 -0700 (PDT)

> From: Antonio Quartulli <ordex@autistici.org>
> Date: Sat, 17 Aug 2013 13:04:44 +0200
>=20
>>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-da=
vem
>  ...
>> Antonio Quartulli (1):
>>       batman-adv: properly end seq_read session
>>=20
>> Linus L=FCssing (1):
>>       batman-adv: check return type of unicast packet preparations
>=20
> The change by Linus is not in that tree.
>=20
> When I pulled I only got the seq_rea fix.

Nevermind, in fact, I see that only Linus's unicast fix was in there,
which is what you intended.

Sorry for the false alarm.
