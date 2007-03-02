From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Fri, 02 Mar 2007 15:43:28 -0800 (PST)
Message-ID: <20070302.154328.89062714.davem@davemloft.net>
References: <m3zm6vk6kd.fsf@maximus.localdomain>
	<20070302.112325.39160082.davem@davemloft.net>
	<m3d53r6wte.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, jeff@garzik.org,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992762AbXCBXn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 18:43:29 -0500
In-Reply-To: <m3d53r6wte.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 03 Mar 2007 00:38:05 +0100

> Switching HDLC devices from Ethernet-framing mode caused stale ethernet
> function assignments within net_device.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

This looks good to me, I think I'll apply it :-)

Thanks!
