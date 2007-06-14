From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Add missing break to TCP option parsing code
Date: Thu, 14 Jun 2007 13:00:55 -0700 (PDT)
Message-ID: <20070614.130055.112852088.davem@davemloft.net>
References: <Pine.LNX.4.64.0706141235470.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751118AbXFNUBB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 16:01:01 -0400
In-Reply-To: <Pine.LNX.4.64.0706141235470.15358@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 14 Jun 2007 12:37:22 +0300 (EEST)

> This flaw does not affect any behavior (currently).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Good catch, patch applied.

Thanks!
