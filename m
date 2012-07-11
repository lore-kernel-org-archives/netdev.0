From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/16] Metrics restructuring.
Date: Tue, 10 Jul 2012 23:07:53 -0700 (PDT)
Message-ID: <20120710.230753.888978552341612339.davem@davemloft.net>
References: <20120710.080703.916560084659556593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab2GKGH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:07:56 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B9CBD586999
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 23:07:57 -0700 (PDT)
In-Reply-To: <20120710.080703.916560084659556593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, I've incorporated all the feedback and pushed the result
into net-next:

1) Namespace support for TCP metrics cache.

2) Cleanup address comparisons and add necessary sparse casts.

3) Trailing whitespace.

Thanks everyone.
