From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu, 06 Mar 2008 16:18:07 -0800 (PST)
Message-ID: <20080306.161807.185339076.davem@davemloft.net>
References: <1204800947-21569-1-git-send-email-jonas@southpole.se>
	<1204800947-21569-2-git-send-email-jonas@southpole.se>
	<20080306154150.0ba906fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, greg@kroah.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754604AbYCGASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 19:18:07 -0500
In-Reply-To: <20080306154150.0ba906fa.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 6 Mar 2008 15:41:50 -0800

> So I wouldn't go adding code which uses this thing until it has a correct
> name, and until we've decided that we actually want to live with it.

I personally think it's noise.
