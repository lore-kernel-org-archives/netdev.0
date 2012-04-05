From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: replace continue with break to reduce
 unnecessary loop in xxx_xmarksources
Date: Thu, 05 Apr 2012 05:43:50 -0400 (EDT)
Message-ID: <20120405.054350.1377932707310157878.davem@davemloft.net>
References: <1333618589-13839-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab2DEJnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 05:43:52 -0400
In-Reply-To: <1333618589-13839-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  5 Apr 2012 17:36:29 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> The conditional which decides to skip inactive filters does not
> change with the change of loop index, so it is unnecessary to
> check them many times.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied, thanks.
