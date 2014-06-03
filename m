From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: Remove unwanted debug/error message
Date: Mon, 02 Jun 2014 23:14:10 -0700 (PDT)
Message-ID: <20140602.231410.385953979283113095.davem@davemloft.net>
References: <1401768978-22284-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbaFCGOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 02:14:11 -0400
In-Reply-To: <1401768978-22284-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Tue,  3 Jun 2014 06:16:18 +0200

> In commit cd11cf505318ff24e42f35145f9cdf8596fa1958 I accidentally
> added an error message. I used it for debugging and forgot to remove
> it before submitting the patch.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied, thanks.
