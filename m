From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] bnx2x: Correct EEE statistics gathering
Date: Tue, 24 Jul 2012 13:56:38 -0700 (PDT)
Message-ID: <20120724.135638.1700317796410097539.davem@davemloft.net>
References: <1343114166-30834-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab2GXU4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:56:41 -0400
In-Reply-To: <1343114166-30834-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 24 Jul 2012 10:16:06 +0300

> In boards with 4-ports, Tx LPI statistics were gathered incorrectly.
> This patch guarantees that each pmf will only query its own port for
> these statistics.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
