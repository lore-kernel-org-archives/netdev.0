From: David Miller <davem@davemloft.net>
Subject: net-2.6.23 rebased...
Date: Fri, 06 Jul 2007 14:13:10 -0700 (PDT)
Message-ID: <20070706.141310.74746684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758139AbXGFVMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 17:12:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2F30E290127
	for <netdev@vger.kernel.org>; Fri,  6 Jul 2007 14:13:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I know that Patrick needs this in order to unload his netfilter
patches on me, so I took care of this today.

There was a minor, trivial to resolve, conflict in netpoll.c
but otherwise everything went in perfectly during the rebase.
