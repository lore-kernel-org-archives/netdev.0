From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH net-next] netlink: compiling issue, need a dummy function
 sk_diag_put_rings_cfg when CONFIG_NETLINK_MMAP disabled
Date: Wed, 24 Apr 2013 16:20:52 +0800
Message-ID: <517795E4.3050604@asianux.com>
References: <51779347.2000808@asianux.com> <20130424.041153.1240956751124977482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, xemul@parallels.com, avagin@openvz.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:19115 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757906Ab3DXIVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 04:21:39 -0400
In-Reply-To: <20130424.041153.1240956751124977482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8824=E6=97=A5 16:11, David Miller wrote:
> aFrom: Chen Gang <gang.chen@asianux.com>
> Date: Wed, 24 Apr 2013 16:09:43 +0800
>=20
>> >=20
>> > When disable CONFIG_NETLINK_MMAP, need a dummy function for=20
>> > sk_diag_put_rings_cfg, or will cause compiling issue.
>> >=20
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> This was fixed more than 12 hours ago.
>=20
>=20

Ok, thanks.

--=20
Chen Gang

Asianux Corporation
