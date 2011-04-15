From: David Miller <davem@davemloft.net>
Subject: [PATCH v5 0/7] rtcache removal respin
Date: Fri, 15 Apr 2011 15:39:34 -0700 (PDT)
Message-ID: <20110415.153934.112606188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753269Ab1DOWkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:40:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 16DD724C088
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:39:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is just a respin of the routing cache removal patches,
to deal with conflicts that have arisen since v4.

I'm leaving out the netlink patch from now on because that
change is totally unrelated to this work.

No functional changes are present since the last respin.
