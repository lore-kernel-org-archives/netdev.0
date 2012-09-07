From: David Miller <davem@davemloft.net>
Subject: Re: |PATCH] seeq: Add missing spinlock init
Date: Fri, 07 Sep 2012 12:59:51 -0400 (EDT)
Message-ID: <20120907.125951.1083769704534390217.davem@davemloft.net>
References: <20120906124705.2631ae01@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab2IGQ7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 12:59:53 -0400
In-Reply-To: <20120906124705.2631ae01@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>
Date: Thu, 6 Sep 2012 12:47:05 +0200

> It doesn't seem this spinlock was properly initialized.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>

Applied.
