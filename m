From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] af_unix: remove 0 assignment on static
Date: Tue, 07 Oct 2014 17:03:34 -0400 (EDT)
Message-ID: <20141007.170334.1642010479995041045.davem@davemloft.net>
References: <1412715735-6757-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbaJGVDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 17:03:36 -0400
In-Reply-To: <1412715735-6757-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  7 Oct 2014 23:02:15 +0200

> static values are automatically initialized to 0
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> V2: replace NULL by 0 in description

Applied, thanks Fabian.
