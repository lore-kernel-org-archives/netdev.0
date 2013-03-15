From: David Miller <davem@davemloft.net>
Subject: Re: net: clean leftover of COMPAT_NET_DEV_OPS removal
Date: Fri, 15 Mar 2013 08:31:28 -0400 (EDT)
Message-ID: <20130315.083128.875817499053793089.davem@davemloft.net>
References: <1363229845.5774.2.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: fernando_b1@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab3COMbM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 08:31:12 -0400
In-Reply-To: <1363229845.5774.2.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando_b1@lab.ntt.co.jp>
Date: Thu, 14 Mar 2013 11:57:25 +0900

> COMPAT_NET_DEV_OPS was removed a while back and with it the definitio=
n of
> netdev_resync_ops() went away. Let's finish the clean-up.
>=20
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

Applied, thanks.
