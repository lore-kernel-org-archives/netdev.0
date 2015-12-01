From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qede/qed: Implement various ethtool
 operations
Date: Tue, 01 Dec 2015 16:02:57 -0500 (EST)
Message-ID: <20151201.160257.716100186330915592.davem@davemloft.net>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Sudarsana.Kalluru@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbbLAVC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:02:58 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 30 Nov 2015 12:25:00 +0200

> This series adds several new ethtool operations to qede:
>   - {get, set}_channels
>   - {get, set}_ringparam
>   - set_phys_id
>   - nway_reset
>   - {get, set}_pauseparam
> As well as extending the qed APIs to support these commands.
> 
> Dave, please consider applying this series to `net-next'.

Series applied, thank you.
