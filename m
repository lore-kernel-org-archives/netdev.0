From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next] net: usbnet: update addr_assign_type
 if appropriate
Date: Thu, 05 Sep 2013 12:45:31 -0400 (EDT)
Message-ID: <20130905.124531.1161933921423677178.davem@davemloft.net>
References: <1378280552-12632-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab3IEQpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:45:33 -0400
In-Reply-To: <1378280552-12632-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed,  4 Sep 2013 09:42:32 +0200

> This module generates a common default address on init,
> using eth_random_addr. Set addr_assign_type to let
> userspace know the address is random unless it was
> overridden by the minidriver.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> Acked-by: Oliver Neukum <oliver@neukum.org>

Applied.
