From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] asix: AX88172A driver depends on phylib
Date: Thu, 19 Jul 2012 10:50:35 -0700 (PDT)
Message-ID: <20120719.105035.1388174968455315721.davem@davemloft.net>
References: <1342699339-13871-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	kernel-janitors@vger.kernel.org
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab2GSRug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:50:36 -0400
In-Reply-To: <1342699339-13871-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Thu, 19 Jul 2012 14:02:19 +0200

> Since commit 16626b0cc3d5afe250850f96759b241f8a403b52 the asix
> driver depends on the phylib. Select phylib when the asix driver is
> selected.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: kernel-janitors@vger.kernel.org
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied.
