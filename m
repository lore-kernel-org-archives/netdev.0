From: Greg KH <greg@kroah.com>
Subject: benet now in drivers/net/, remove from staging?
Date: Tue, 17 Mar 2009 13:05:24 -0700
Message-ID: <20090317200524.GA3938@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathyap@serverengines.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:32820 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750835AbZCQUHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 16:07:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the benet driver is properly in drivers/net/ should I delete it
from drivers/staging/benet?

Or is there some reason for both to live on?

thanks,

greg k-h
