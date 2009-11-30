From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/20] Batch network namespace cleanup
Date: Mon, 30 Nov 2009 09:07:39 +0100
Message-ID: <4B137D4B.8050803@gmail.com>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53939 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbZK3IHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 03:07:43 -0500
In-Reply-To: <m1ljhodbtw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :

> Eric W. Biederman (20):
>       net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
>       net: Implement for_each_netdev_reverse.
>       net: Batch network namespace destruction.
>       net: Automatically allocate per namespace data.
>       net: Simplify loopback and improve batching.
>       net: Simplfy default_device_exit and improve batching.
>       net: Simplify the bond drivers pernet operations.
>       net: Simplify vlan pernet operations.
>       net: Simplify af_key pernet operations.
>       net: Simplify conntrack_proto_dccp pernet operations.
>       net: Simplify conntrack_proto_gre pernet operations.
>       net: Simplify ppp_generic pernet operations.
>       net: Simplify pppoe pernet operations.
>       net: Simplify pppol2tp pernet operations.
>       net: Simplify phonet pernet operations.
>       net: Simplify ip_gre pernet operations.
>       net: Simplify ipip pernet operations.
>       net: Simplify ip6_tunnel pernet operations.
>       net: Simplify ipip6 aka sit pernet operations.
>       net: remove [un]register_pernet_gen_... and update the docs.
>=20

It seems list received part of your patches Eric

01, 07-20 are OK,   02-06 are missing

Thanks
