From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .26
Date: Tue, 13 May 2008 01:18:28 -0700 (PDT)
Message-ID: <20080513.011828.193690369.davem@davemloft.net>
References: <20080513055623.GA16928@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756641AbYEMISe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 04:18:34 -0400
In-Reply-To: <20080513055623.GA16928@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 13 May 2008 01:56:23 -0400

> 
> Notes:
> - lotsa LOC change in sfc, but it's a new driver, so no possible
>   regressions
> 
> - we add some non-net exports required for ehea (drivers/base/memory.c)

Pulled, thanks a lot Jeff.
