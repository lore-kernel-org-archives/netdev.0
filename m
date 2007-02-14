From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 0/2] natsemi: Support Aculab E1/T1 cPCI carrier cards
Date: Wed, 14 Feb 2007 10:02:03 +0000
Message-ID: <20070214100203.413293000@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4399 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbXBNKir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 05:38:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add support for the Aculab E1/T1 cPCI carrier card to the
natsemi driver.  The first patch provides support for using the MII port
with no PHY and the second adds the quirk required to configure the
card.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
