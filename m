From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: skge 1.6
Date: Wed, 21 Jun 2006 10:46:14 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250024222@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'david@mantara.com'" <david@mantara.com>,
	"'Krzysztof Oledzki'" <olel@ans.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:9661 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1751267AbWFUIqS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 04:46:18 -0400
To: "'Stephen Hemminger'" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Crashing keeps on, but I want to emphasize that it crashes during excessive
Rx not Tx.
I can copy a 1GB file smoothly from the server, but in the other direction
after some seconds the box hangs.

Sorry, couldn't test other then SMB yet on our production system.

Daniel
