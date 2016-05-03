From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] qed: Apply tunnel configurations after PF
 start
Date: Tue, 03 May 2016 15:48:44 -0400 (EDT)
Message-ID: <20160503.154844.1585922472863160260.davem@davemloft.net>
References: <1462184164-22650-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbcECTsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 15:48:47 -0400
In-Reply-To: <1462184164-22650-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Mon, 2 May 2016 06:16:04 -0400

> Configure and enable various tunnels on the
> adapter after PF start.
> 
> This change was missed as a part of
> 'commit 464f664501816ef5fbbc00b8de96f4ae5a1c9325
> ("qed: Add infrastructure support for tunneling")'
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>

Applied.
