From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] [TCP]: Prior_fackets can be replaced by
 highest_sack seq
Date: Thu, 15 Nov 2007 19:44:31 -0800 (PST)
Message-ID: <20071115.194431.21218315.davem@davemloft.net>
References: <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754059AbXKPDoc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:44:32 -0500
In-Reply-To: <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:30 +0200

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Every simplification like this is like one less potential
bug to fix :-)

Patch applied to net-2.6.25, thanks!
