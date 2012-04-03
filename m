From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Tue, 03 Apr 2012 19:48:45 -0400 (EDT)
Message-ID: <20120403.194845.437828259714310359.davem@davemloft.net>
References: <20120403.184004.2056266545823149252.davem@davemloft.net>
	<1333494088.2695.29.camel@joe2Laptop>
	<4F7B8884.7070901@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCXvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:51:06 -0400
In-Reply-To: <4F7B8884.7070901@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Tue, 3 Apr 2012 19:32:20 -0400

> David, I concur that it would be useful to make this canonical somewhere,
> since folks who are not aware of your preferences will obviously follow the
> CodingStyle document until corrected by you, which seems like a pain for
> you.  I suspect a modified version of Joe's original CodingStyle change,
> along with a comparable change in checkpatch, is the most "scalable" solution.

I'll try to find time to address this.
