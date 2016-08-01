From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ethernet: ax88796: avoid null pointer
 dereference
Date: Mon, 01 Aug 2016 13:43:59 -0700 (PDT)
Message-ID: <20160801.134359.2045525332751667811.davem@davemloft.net>
References: <1469951924-20276-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbcHAUuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:50:12 -0400
In-Reply-To: <1469951924-20276-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 09:58:44 +0200

> If platform_get_resource fails, mem2 is null.
> Do not dereference null.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
