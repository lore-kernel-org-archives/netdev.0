From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: remove dependency FSL_SOC for Gianfar
Date: Thu, 25 Jun 2015 02:14:13 -0700 (PDT)
Message-ID: <20150625.021413.321576291322782954.davem@davemloft.net>
References: <1435203278-40383-1-git-send-email-b18965@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, ogerlitz@mellanox.com,
	hariprasad@chelsio.com, claudiu.manoil@freescale.com,
	shawn.guo@linaro.org, jason.jin@freescale.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, alison.wang@freescale.com
To: b18965@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbFYJCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 05:02:20 -0400
In-Reply-To: <1435203278-40383-1-git-send-email-b18965@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alison Wang <b18965@freescale.com>
Date: Thu, 25 Jun 2015 11:34:38 +0800

> CONFIG_GIANFAR is not depended on FSL_SOC, it
> can be built on non-PPC platforms.
> 
> Signed-off-by: Alison Wang <alison.wang@freescale.com>

Applied.
