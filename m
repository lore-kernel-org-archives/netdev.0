From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cpts: add missing kconfig dependency
Date: Mon, 26 Nov 2012 17:23:43 -0500 (EST)
Message-ID: <20121126.172343.219794518162131020.davem@davemloft.net>
References: <1353931638-1023-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	cyril@ti.com, mugunthanvnm@ti.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132Ab2KZWXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:23:46 -0500
In-Reply-To: <1353931638-1023-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 26 Nov 2012 13:07:18 +0100

> The Common Platform Time Sync function of the CPSW does not depend the
> CPSW configuration option as it should. This patch fixes the issue by
> adding the dependency.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied.
