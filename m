From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix mdio_read and update mdio_write according to
 hw specs
Date: Wed, 9 Jun 2010 08:18:25 +0200
Message-ID: <20100609061825.GA7087@electric-eye.fr.zoreil.com>
References: <BD599B881C1D407DA7BC93A9244650B0@realtek.com.tw>
 <1276060930-15697-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayeswang <hayeswang@realtek.com>
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.185.140-88.rev.gaoland.net ([88.140.185.30]:51488 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752701Ab0FIGT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 02:19:27 -0400
Content-Disposition: inline
In-Reply-To: <1276060930-15697-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=C3=A4s <timo.teras@iki.fi> :
> Realtek confirmed that a 20us delay is needed after mdio_read and
> mdio_write operations. Reduce the delay in mdio_write, and add it
> to mdio_read too. Also add a comment that the 20us is from hw specs.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>

Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>
