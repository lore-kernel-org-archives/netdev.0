From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X.25: Fix address field length calculation
Date: Thu, 17 Oct 2013 16:04:59 -0400 (EDT)
Message-ID: <20131017.160459.1507161094032710327.davem@davemloft.net>
References: <525D5131.9070007@datus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: GKelleter@datus.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525D5131.9070007@datus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Kelleter, G=FCnther <GKelleter@datus.com>
Date: Tue, 15 Oct 2013 14:29:06 +0000

> Addresses are BCD encoded, not ASCII. x25_addr_ntoa got it right.
>=20
> Signed-off-by: Guenther Kelleter <gkelleter@datus.com>
> ---
> Wrong length calculation leads to rejection of CALL ACCEPT packets.

This patch doesn't apply because it was severely corrupted by your
email client, turn off all encodings etc. in your client, send
a test patch to yourself, and do not submit this patch again until
you can successfully apply the patch you receive in those test emails.

Thanks.
