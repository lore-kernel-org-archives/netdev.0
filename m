From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 4/5] enic: Clean up: Remove support for an older
 version of hardware
Date: Sat, 05 Feb 2011 17:57:02 -0800 (PST)
Message-ID: <20110205.175702.226777511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751640Ab1BFB41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Feb 2011 20:56:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If this hardware ever shipped to any customers, you cannot
simply remove support for it.

Such code must be retained.
