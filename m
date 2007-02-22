From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP] Cleanup: struct *sock argument renamed: sp -> sk
Date: Thu, 22 Feb 2007 01:14:16 -0800 (PST)
Message-ID: <20070222.011416.94074097.davem@davemloft.net>
References: <Pine.LNX.4.64.0702201712370.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932922AbXBVJOT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 04:14:19 -0500
In-Reply-To: <Pine.LNX.4.64.0702201712370.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 20 Feb 2007 17:17:02 +0200 (EET)

> In general, TCP code uses "sk" for struct sock pointer.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to tcp-2.6, thank you.
