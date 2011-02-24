From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/26] Tonight's xfrm 'const' pass.
Date: Wed, 23 Feb 2011 23:12:58 -0800 (PST)
Message-ID: <20110223.231258.226775119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab1BXHMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:22 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CA25224C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:12:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This time we hit xfrm_address_t, template pointers, etc.

Most of the remaining work will be in the key managers.
