From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix XFRMA_MARK extraction in xfrm_mark_get
Date: Wed, 30 Jun 2010 10:41:22 -0700 (PDT)
Message-ID: <20100630.104122.24593057.davem@davemloft.net>
References: <4C2AF8EE.8030508@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: andreas.steffen@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0F3RlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:41:09 -0400
In-Reply-To: <4C2AF8EE.8030508@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Steffen <andreas.steffen@strongswan.org>
Date: Wed, 30 Jun 2010 09:57:34 +0200

> Determine the size of the xfrm_mark struct, not of its pointer.
> 
> Signed-off-by: Andreas Steffen <andreas.steffen@strongswan.org>

Applied, thanks.
