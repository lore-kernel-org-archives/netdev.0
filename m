From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: neterion: replace ip_fast_csum with
 csum_replace2
Date: Mon, 18 Mar 2013 13:02:49 -0400 (EDT)
Message-ID: <20130318.130249.552186044757498712.davem@davemloft.net>
References: <1363595688-16004-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3CRRCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:02:51 -0400
In-Reply-To: <1363595688-16004-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 18 Mar 2013 16:34:48 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> replace ip_fast_csum with csum_replace2 to save cpu cycles
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
