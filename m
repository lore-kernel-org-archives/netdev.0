From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: kernel-doc compliant documentation for
 net_device
Date: Thu, 31 Jul 2014 21:34:45 -0700 (PDT)
Message-ID: <20140731.213445.1149323342462833633.davem@davemloft.net>
References: <1406744856-5685-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: karoly.kemeny@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbaHAEeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 00:34:46 -0400
In-Reply-To: <1406744856-5685-1-git-send-email-karoly.kemeny@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karoly Kemeny <karoly.kemeny@gmail.com>
Date: Wed, 30 Jul 2014 20:27:36 +0200

> Net_device is a vast and important structure, but it has no kernel-doc
> compliant documentation. This patch extracts the comments from the structure
> to clean it up, and let the scripts extract documentation from it. I know that
> the patch is big, but it's just reordering of comments into the appropriate 
> form, and adding a few more, for the missing members.
> 
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> Acked-by: Randy Dunlap <rdunlap@infradead.org>

Applied to net-next, thanks.
