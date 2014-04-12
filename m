From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/apne: replace IS_ERR and PTR_ERR with
 PTR_ERR_OR_ZERO
Date: Sat, 12 Apr 2014 02:01:02 -0400 (EDT)
Message-ID: <20140412.020102.1693825264607282081.davem@davemloft.net>
References: <1397205457-24287-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, geert@linux-m68k.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbaDLGBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 02:01:07 -0400
In-Reply-To: <1397205457-24287-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 11 Apr 2014 16:37:37 +0800

> This patch fixes coccinelle error regarding usage of IS_ERR and
> PTR_ERR instead of PTR_ERR_OR_ZERO.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied.
