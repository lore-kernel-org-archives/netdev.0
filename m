From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/1] qed/qede: use 8.7.3.0 FW.
Date: Wed, 17 Feb 2016 16:04:53 -0500 (EST)
Message-ID: <20160217.160453.1555664017999118297.davem@davemloft.net>
References: <1455560555-813-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161042AbcBQVEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:04:55 -0500
In-Reply-To: <1455560555-813-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Mon, 15 Feb 2016 13:22:35 -0500

> From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> 
> This patch moves the qed* driver into utilizing the 8.7.3.0 FW.
> This new FW is required for a lot of new SW features, including:
>   - Vlan filtering offload
>   - Encapsulation offload support
>   - HW ingress aggregations
> As well as paving the way for the possibility of adding storage protocols
> in the future.
> 
> V2:
>  - Fix kbuild test robot error/warnings.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied, thanks.
