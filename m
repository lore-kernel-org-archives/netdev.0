From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: thunderx: avoid null pointer dereference
Date: Thu, 19 May 2016 11:25:50 -0700 (PDT)
Message-ID: <20160519.112550.1461536215214747775.davem@davemloft.net>
References: <1463514038-9008-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932794AbcESSZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:25:52 -0400
In-Reply-To: <1463514038-9008-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Tue, 17 May 2016 21:40:38 +0200

> In function bgx_lmac_handler only use a member of
> lmac after checking it is not null.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
