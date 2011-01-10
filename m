From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] offloading: Accept NETIF_F_HW_CSUM for all
 protocols.
Date: Sun, 09 Jan 2011 23:36:32 -0800 (PST)
Message-ID: <20110109.233632.232898185.davem@davemloft.net>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751009Ab1AJHgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:36:00 -0500
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for doing this work Jesse, I've applied all of these patches.

I added a "net " prefix to the commit header lines so that people know
what kind of "offloading" these changes are about :-)
