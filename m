From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Ensure that we unshare skbs prior to calling
 pskb_may_pull in bonding driver
Date: Thu, 20 Jan 2011 16:47:23 -0800 (PST)
Message-ID: <20110120.164723.73670910.davem@davemloft.net>
References: <1295550151-25913-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753873Ab1AUAqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:46:49 -0500
In-Reply-To: <1295550151-25913-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 20 Jan 2011 14:02:31 -0500

> Recently reported oops:

Applied, but please compose reasonable Subject lines with your patches,
always begin the line with a subsystem tag followed by a colon.

This way we get

	bonding: Foo bar baz

instead of

	Foo bar baz in the bonding driver

Thanks.
