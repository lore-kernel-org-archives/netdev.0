From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Mon, 27 May 2013 02:30:39 -0700 (PDT)
Message-ID: <20130527.023039.165030551447378095.davem@davemloft.net>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
	<87a9ngddfv.fsf@nemi.mork.no>
	<8761y4dcm7.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab3E0Jaj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 05:30:39 -0400
In-Reply-To: <8761y4dcm7.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 27 May 2013 10:57:04 +0200

> Bj=F8rn Mork <bjorn@mork.no> writes:
>=20
>> I see that you don't bother listen to advice.
>>
>>  ERROR: "nd_tbl" [drivers/net/vxlan.ko] undefined!
>=20
>=20
> And building with CONFIG_IPV6=3Dm is even more fun:
>=20
> ERROR: "in6addr_linklocal_allnodes" [net/ipv6/ipv6.ko] undefined!
> ERROR: "in6addr_interfacelocal_allrouters" [net/ipv6/ipv6.ko] undefin=
ed!
> ERROR: "in6addr_interfacelocal_allnodes" [net/ipv6/ipv6.ko] undefined=
!
> ERROR: "in6addr_linklocal_allrouters" [net/ipv6/ipv6.ko] undefined!
> ERROR: "in6addr_sitelocal_allrouters" [net/ipv6/ipv6.ko] undefined!
> ERROR: "in6addr_any" [net/ipv6/ipv6.ko] undefined!
> ERROR: "nd_tbl" [drivers/net/vxlan.ko] undefined!
>=20
>=20
> Nice...

Cong, this is getting utterly rediculous.

And you had the nerve to complain when we were unwilling to merge this
not-ready garbage into 3.10?!?!  Are you kidding me?
