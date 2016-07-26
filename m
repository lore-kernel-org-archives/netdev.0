From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Fix setting/clearing bit in completion bitmap
Date: Mon, 25 Jul 2016 21:41:41 -0700 (PDT)
Message-ID: <20160725.214141.261775983205991097.davem@davemloft.net>
References: <1469462866-14103-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manish.chopra@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbcGZElm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 00:41:42 -0400
In-Reply-To: <1469462866-14103-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 25 Jul 2016 19:07:46 +0300

> From: Manish Chopra <manish.chopra@qlogic.com>
> 
> Slowpath completion handling is incorrectly changing
> SPQ_RING_SIZE bits instead of a single one.
> 
> Fixes: 76a9a3642a0b ("qed: fix handling of concurrent ramrods")
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
