From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Remove the inet_lro library
Date: Wed, 17 Feb 2016 16:16:20 -0500 (EST)
Message-ID: <20160217.161620.999480340574338356.davem@davemloft.net>
References: <20160215212351.GB5231@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161462AbcBQVQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:16:22 -0500
In-Reply-To: <20160215212351.GB5231@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 15 Feb 2016 21:23:52 +0000

> The old inet_lro library has been deprecated ever since GRO was
> introduced, but there are still a few drivers using it.  Convert
> them to GRO and remove it.

A nice and long overdue cleanups.

Applied, thanks Ben.
