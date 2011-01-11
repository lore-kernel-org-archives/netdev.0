From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CAIF: Fix IPv6 support in receive path for GPRS/3G
Date: Mon, 10 Jan 2011 16:12:08 -0800 (PST)
Message-ID: <20110110.161208.73676756.davem@davemloft.net>
References: <1294401428-2085-1-git-send-email-sjurbren@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kumar.sanghvi@stericsson.com,
	sjur.brandeland@stericsson.com
To: sjurbren@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751558Ab1AKALg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 19:11:36 -0500
In-Reply-To: <1294401428-2085-1-git-send-email-sjurbren@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@stericsson.com>
Date: Fri, 07 Jan 2011 12:57:08 +0100

> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
>=20
> Checks version field of IP in the receive path for GPRS/3G data
> and appropriately sets the value of skb->protocol.
>=20
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied, thanks.
