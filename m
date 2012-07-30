From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] mISDN: Bugfix only few bytes are transfered on a
 connection
Date: Sun, 29 Jul 2012 23:19:38 -0700 (PDT)
Message-ID: <20120729.231938.227853352544807247.davem@davemloft.net>
References: <1343582113-14752-1-git-send-email-keil@b1-systems.de>
	<1343582113-14752-2-git-send-email-keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tobias.powalowski@googlemail.com
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab2G3GTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:19:43 -0400
In-Reply-To: <1343582113-14752-2-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Sun, 29 Jul 2012 19:15:13 +0200

> The test for the fillempty condition was wrong in one place.
> Changed the variable to the right boolean type.
> 
> Signed-off-by: Karsten Keil <keil@b1-systems.de>

Applied.
