From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/fsl_ucc: Do not prefix header guard with
 CONFIG_
Date: Wed, 08 Jun 2016 11:08:41 -0700 (PDT)
Message-ID: <20160608.110841.1742678705562218191.davem@davemloft.net>
References: <1465378828-7077-1-git-send-email-andreas.ziegler@fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: qiang.zhao@nxp.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, valentinrothberg@gmail.com,
	linux-kernel@vger.kernel.org
To: andreas.ziegler@fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbcFHSIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:08:50 -0400
In-Reply-To: <1465378828-7077-1-git-send-email-andreas.ziegler@fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Ziegler <andreas.ziegler@fau.de>
Date: Wed,  8 Jun 2016 11:40:28 +0200

> The CONFIG_ prefix should only be used for options which
> can be configured through Kconfig and not for guarding headers.
> 
> Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>

Applied.
