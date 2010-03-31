From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next-2.6 v2] virtio_net: missing sg_init_table
Date: Tue, 30 Mar 2010 18:32:19 -0700 (PDT)
Message-ID: <20100330.183219.40571153.davem@davemloft.net>
References: <1269887518.13277.13.camel@localhost.localdomain>
	<4BB10010.5060505@mathtm.de>
	<1269911955.14013.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thomas@mathtm.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269911955.14013.4.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Shirley Ma <mashirle@us.ibm.com>
Date: Mon, 29 Mar 2010 18:19:15 -0700

> Add missing sg_init_table for sg_set_buf in virtio_net which
> induced in defer skb patch.
>=20
> Reported-by: Thomas M=FCller <thomas@mathtm.de>
> Tested-by: Thomas M=FCller <thomas@mathtm.de>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

Applied, thanks.
