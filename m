From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix set_setting for some PHYs
Date: Thu, 24 Jul 2014 18:02:32 -0700 (PDT)
Message-ID: <20140724.180232.2026219404045980853.davem@davemloft.net>
References: <1406142777-24267-1-git-send-email-dkravkov@lb-tlvb-dmitry.il.qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com,
	Yaniv.Rosner@qlogic.com, Dmitry.Kravkov@qlogic.com
To: dkravkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaGYBCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 21:02:33 -0400
In-Reply-To: <1406142777-24267-1-git-send-email-dkravkov@lb-tlvb-dmitry.il.qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dkravkov@gmail.com>
Date: Wed, 23 Jul 2014 22:12:57 +0300

> From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> 
> Allow set_settings() to complete succesfully even if link is
> not estabilished and port type isn't known yet.
> 
> Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

Applied, thanks.
