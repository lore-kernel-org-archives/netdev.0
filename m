From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: s2io: simplify logical constraint
Date: Mon, 01 Aug 2016 13:44:29 -0700 (PDT)
Message-ID: <20160801.134429.1368743498960997806.davem@davemloft.net>
References: <1469958837-1044-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbcHAUpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:45:22 -0400
In-Reply-To: <1469958837-1044-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 11:53:57 +0200

> (!A || (A && B)) is equivalent to (!A || B)
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
