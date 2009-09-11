From: David Miller <davem@davemloft.net>
Subject: net-next-2.6 submission delayed...
Date: Fri, 11 Sep 2009 14:03:07 -0700 (PDT)
Message-ID: <20090911.140307.40572734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756583AbZIKVCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 17:02:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 42633C8C423
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 14:03:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some tg3 driver change craps out the card on my workstation
after just a few TCP packets back and forth, so I have to
bisect and debug this before I can ask Linus to pull.

I believe there was a similar report made a week or so
ago.
