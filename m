From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sock_diag: fix filter code sent to userspace
Date: Mon, 10 Jun 2013 22:25:11 -0700 (PDT)
Message-ID: <20130610.222511.1291669002612600976.davem@davemloft.net>
References: <1370439055-4239-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3FKFZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 01:25:14 -0400
In-Reply-To: <1370439055-4239-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  5 Jun 2013 15:30:55 +0200

> Filters need to be translated to real BPF code for userland, like SO_GETFILTER.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.
