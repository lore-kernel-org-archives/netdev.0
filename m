From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix two sparse warnings introduced by
 IGMP/MLD parsing exports
Date: Mon, 04 May 2015 19:20:17 -0400 (EDT)
Message-ID: <20150504.192017.843030550939228570.davem@davemloft.net>
References: <1430777976-4014-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linus.luessing@c0d3.blue
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430777976-4014-1-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Tue,  5 May 2015 00:19:35 +0200

>> net/core/skbuff.c:4108:13: sparse: incorrect type in assignment (dif=
ferent base types)
>> net/ipv6/mcast_snoop.c:63 ipv6_mc_check_exthdrs() warn: unsigned 'of=
fset' is never less than zero.
>=20
> Introduced by 9afd85c9e4552b276e2f4cfefd622bdeeffbbf26
> ("net: Export IGMP/MLD message validation code")
>=20
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Applied, thank you.
