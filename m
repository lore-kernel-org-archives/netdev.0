From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] pfkey/xfrm SAD/SPD flushing fixes
Date: Fri, 19 Feb 2010 13:12:42 -0800 (PST)
Message-ID: <20100219.131242.129763444.davem@davemloft.net>
References: <flush-fix-xfrm>
	<1266580842-10608-1-git-send-email-hadi@cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40778
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751346Ab0BSVMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 16:12:25 -0500
In-Reply-To: <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Fri, 19 Feb 2010 07:00:39 -0500

> From: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> This patch set does split for pfkey response for flushing and 
> makes sure events for flush are generated only when we have
> a non-empty SAD/SPD. We maintain current behavior of silence
> when a table is empty.

All applied, thanks Jamal.
