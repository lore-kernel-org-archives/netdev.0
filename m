From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix ethtool get settings
Date: Sat, 21 Apr 2012 16:38:31 -0400 (EDT)
Message-ID: <20120421.163831.914406650119084826.davem@davemloft.net>
References: <20120419212124.GA31818@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab2DUUie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:38:34 -0400
In-Reply-To: <20120419212124.GA31818@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Thu, 19 Apr 2012 16:21:24 -0500

> Please apply to net-next.

This doesn't belong in the body of the commit message.

> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Please resubmit this, but with a commit message which describes
what exactly was wrong with ethtool get setting in this driver,
and how you fixed it.
