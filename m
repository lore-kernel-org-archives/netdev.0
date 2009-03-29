From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: Two quick GRO conversions.
Date: Sun, 29 Mar 2009 03:17:19 -0700 (PDT)
Message-ID: <20090329.031719.07026389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750749AbZC2KRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:17:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 07376C8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:17:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I had been meaning to do these, and they are simple enough to add now
as we can revert them easily if there are any problems.
