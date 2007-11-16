From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] [TCP]: Earlier SACK block verification &
 simplify access to them
Date: Thu, 15 Nov 2007 19:50:21 -0800 (PST)
Message-ID: <20071115.195021.263014362.davem@davemloft.net>
References: <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44311
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755535AbXKPDuW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:50:22 -0500
In-Reply-To: <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:32 +0200

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This is fine, and I can see how it sets things up for the
new "fastpath" code.  Applied to net-2.6.25, thanks!
