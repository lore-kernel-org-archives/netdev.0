From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 0/2] natsemi: Support Aculab E1/T1 cPCI carrier cards
Date: Mon, 19 Feb 2007 20:15:38 +0000
Message-ID: <20070219201538.420238000@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:1558 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932615AbXBSUX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 15:23:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for the Aculab E1/T1 cPCI carrier card to the
natsemi driver.  The first patch provides support for using the MII port
with no PHY and the second adds the quirks required to detect and
configure the card.

This revision should address the issues raised by Jeff over the weekend.
Apologies if I've missed anything.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
