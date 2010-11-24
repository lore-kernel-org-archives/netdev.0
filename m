From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] ethoc: Add device tree configuration
Date: Wed, 24 Nov 2010 11:35:37 -0800 (PST)
Message-ID: <20101124.113537.245416870.davem@davemloft.net>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	<1290606058-26703-2-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753088Ab0KXTfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:35:11 -0500
In-Reply-To: <1290606058-26703-2-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 24 Nov 2010 14:40:51 +0100

> This patch adds the ability to describe ethernet devices via a flattened
> device tree.  As device tree remains an optional feature, these bits all
> need to be guarded by CONFIG_OF ifdefs.
> 
> MAC address is settable via the device tree parameter "local-mac-address";
> however, the selection of the phy id is limited to probing, for now.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
 ...
> +	} 

Trailing whitespace.
