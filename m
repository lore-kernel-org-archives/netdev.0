From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qed: Reset the enable flag for eth protocol.
Date: Wed, 25 May 2016 12:32:56 -0700 (PDT)
Message-ID: <20160525.123256.230057350325928594.davem@davemloft.net>
References: <1464081923-29368-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbcEYTc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:32:58 -0400
In-Reply-To: <1464081923-29368-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Tue, 24 May 2016 05:25:23 -0400

> This patch fixes the coding error in determining the enable flag for
> the application/protocol. The enable flag should be set for all protocols
> but the eth.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
