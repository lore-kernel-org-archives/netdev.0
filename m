From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove unused define from loopback driver
Date: Wed, 12 Dec 2007 11:00:31 -0800 (PST)
Message-ID: <20071212.110031.253747890.davem@davemloft.net>
References: <475FF3E6.9030507@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751621AbXLLTAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:00:32 -0500
In-Reply-To: <475FF3E6.9030507@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 12 Dec 2007 17:44:54 +0300

> The LOOPBACK_OVERHEAD is not used in this file at all.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25, thanks.
