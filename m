From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] netfilter: ipvs: remove the unused variable
Date: Fri, 27 Dec 2013 12:21:37 +0900
Message-ID: <20131227032137.GB3795@verge.net.au>
References: <52B258A9.70002@huawei.com>
 <alpine.LFD.2.11.1312190912090.1749@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wang Weidong <wangweidong1@huawei.com>, wensong@linux-vs.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59421 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab3L0DVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 22:21:39 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1312190912090.1749@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 09:17:17AM +0200, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Thu, 19 Dec 2013, Wang Weidong wrote:
>=20
> > when I built the netfilter, I got that:
> > net/netfilter/ipvs/ip_vs_sync.c: In function sync_thread_master=E2=80=
=99:
> > net/netfilter/ipvs/ip_vs_sync.c:1640: warning: unused variable =E2=80=
=98ret=E2=80=99
>=20
> 	There is another patch that we plan to apply but
> due to possible merge conflict it was delayed:
>=20
> http://marc.info/?t=3D138426695600002&r=3D1&w=3D2
> http://marc.info/?t=3D138426469400008&r=3D1&w=3D2
>=20
> 	May be it is time to apply it...

Thanks, I have done so.
