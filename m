From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 3/3] netxen: add hardware LRO support
Date: Wed, 05 Aug 2009 12:41:24 -0700 (PDT)
Message-ID: <20090805.124124.17926716.davem@davemloft.net>
References: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
	<1249493649-26336-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org,
	narender.kumar@qlogic.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbZHETlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:41:15 -0400
In-Reply-To: <1249493649-26336-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed,  5 Aug 2009 10:34:09 -0700

> Add support to handle aggregate packets from firmware.
> Local TCP flows are automatically identified by firmware
> based on the dest IP hash added by driver for local IP
> addresses.
> 
> The packets are sent down on the jumbo rx ring.
> 
> Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
