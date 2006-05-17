From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: skge driver oops
Date: Wed, 17 May 2006 11:32:41 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250024195@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'Stephen Hemminger'" <shemminger@osdl.org>,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:45236 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1750742AbWEQJct
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 05:32:49 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As David and me are using SMP systems when it's crashing, should I give a
non-SMP kernel a try, to see if it's some kind of race conditon?

Daniel
