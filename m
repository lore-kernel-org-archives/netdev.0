From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: encx24j600: Fix mask to update LED
 configuration
Date: Sun, 25 Oct 2015 18:24:19 -0700 (PDT)
Message-ID: <20151025.182419.2172459432085357434.davem@davemloft.net>
References: <1445540944-13894-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jringle@gridpoint.com
To: jon@ringle.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbbJZBHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 21:07:42 -0400
In-Reply-To: <1445540944-13894-1-git-send-email-jon@ringle.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jon@ringle.org
Date: Thu, 22 Oct 2015 15:09:04 -0400

> From: Jon Ringle <jringle@gridpoint.com>
> 
> This fixes the mask used to update the LED configuration so that it clears
> the necessary bits as well as setting the bits according to the mask.
> Also reverse the LED configuration to show the Link state + collisions in
> LEDA and the Link state + TX/RX events in LEDB.
> 
> Signed-off-by: Jon Ringle <jringle@gridpoint.com>

Applied, thanks.
