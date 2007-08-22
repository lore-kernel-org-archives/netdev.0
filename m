From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 rebased
Date: Wed, 22 Aug 2007 14:10:26 -0700 (PDT)
Message-ID: <20070822.141026.119862560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763372AbXHVVK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:10:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0E7F8290111
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 14:10:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I needed to pull out the xfrm auditing patch, and I had been
meaning to combine the NAPI struct patch with all the little
bug fixes we've accumulated.

Also, as mentioned here throughout the day, I've also added
Thomas Graf's xfrm_user cleanups and Stephen Hemminger's
netdevice docbook additions.

Enjoy.
