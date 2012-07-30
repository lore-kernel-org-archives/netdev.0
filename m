From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: remove cast around the kmalloc in
 bnx2x_prev_mark_path
Date: Sun, 29 Jul 2012 23:19:27 -0700 (PDT)
Message-ID: <20120729.231927.1444915373773052091.davem@davemloft.net>
References: <1343567963-12389-1-git-send-email-develkernel412222@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: develkernel412222@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2G3GT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:19:28 -0400
In-Reply-To: <1343567963-12389-1-git-send-email-develkernel412222@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <develkernel412222@gmail.com>
Date: Sun, 29 Jul 2012 19:04:23 +0545

> casting the void pointer is redundant (Documentation/CodingStyle)
> 
> Signed-off-by: Devendra Naga <develkernel412222@gmail.com>

Applied.
